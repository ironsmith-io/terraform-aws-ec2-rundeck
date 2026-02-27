package test

import (
	"crypto/tls"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const awsRegion = "us-west-2"

// TestRundeck deploys once and runs all verifications as subtests.
// This avoids duplicate AWS deployments and saves time/cost.
func TestRundeck(t *testing.T) {
	t.Parallel()

	subnetID := os.Getenv("TEST_SUBNET_ID")
	require.NotEmpty(t, subnetID, "TEST_SUBNET_ID must be set")

	// Generate a unique key pair for this test run
	uniqueID := random.UniqueId()
	keyPairName := fmt.Sprintf("rundeck-test-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)
	defer aws.DeleteEC2KeyPair(t, keyPair)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",
		Vars: map[string]interface{}{
			"subnet_id":              subnetID,
			"key_pair_name":          keyPairName,
			"ip_allow_ssh":           []string{"0.0.0.0/0"},
			"ip_allow_https":         []string{"0.0.0.0/0"},
			"enable_ssh":             true,
			"enable_cloudwatch_logs": true,
			"enable_ssm":             true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Collect outputs
	instanceID := terraform.Output(t, terraformOptions, "instance_id")
	publicIP := terraform.Output(t, terraformOptions, "public_ip")
	amiID := terraform.Output(t, terraformOptions, "ami_id")
	serverURL := terraform.Output(t, terraformOptions, "server_url")

	t.Run("outputs_populated", func(t *testing.T) {
		assert.NotEmpty(t, instanceID)
		assert.NotEmpty(t, publicIP)
		assert.NotEmpty(t, amiID)
		assert.True(t, strings.HasPrefix(serverURL, "https://"))
	})

	// Build SSH host using the generated key pair
	host := ssh.Host{
		Hostname:    publicIP,
		SshUserName: "rocky",
		SshKeyPair:  keyPair.KeyPair,
	}

	// Phase 1: Wait for SSH to become reachable
	retry.DoWithRetry(t, "Wait for SSH", 20, 15*time.Second, func() (string, error) {
		return ssh.CheckSshCommandE(t, host, "echo ready")
	})

	// Phase 2: Poll cloud-init status (non-blocking) until done
	// cloud-init installs Java, PostgreSQL, Rundeck, nginx, etc. and can take 10-15 minutes
	// Note: cloud-init 24.x returns non-zero exit for "degraded done" (schema warnings),
	// so we check the output text rather than relying on exit code
	retry.DoWithRetry(t, "Wait for cloud-init to finish", 60, 15*time.Second, func() (string, error) {
		output, err := ssh.CheckSshCommandE(t, host, "sudo cloud-init status 2>&1 || true")
		if err != nil {
			return "", err
		}
		if strings.Contains(output, "done") {
			return output, nil
		}
		return "", fmt.Errorf("cloud-init still running: %s", strings.TrimSpace(output))
	})

	// --- Service checks ---

	t.Run("rundeck_service_running", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "sudo systemctl is-active rundeckd")
		require.NoError(t, err)
		assert.Contains(t, result, "active")
	})

	t.Run("nginx_service_running", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "sudo systemctl is-active nginx")
		require.NoError(t, err)
		assert.Contains(t, result, "active")
	})

	t.Run("postgresql_service_running", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "sudo systemctl is-active postgresql-16")
		require.NoError(t, err)
		assert.Contains(t, result, "active")
	})

	t.Run("cloudwatch_agent_running", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "sudo systemctl is-active amazon-cloudwatch-agent")
		require.NoError(t, err)
		assert.Contains(t, result, "active")
	})

	t.Run("ssm_agent_running", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "sudo systemctl is-active amazon-ssm-agent")
		require.NoError(t, err)
		assert.Contains(t, result, "active")
	})

	// --- Application-level checks ---

	t.Run("https_endpoint_accessible", func(t *testing.T) {
		tlsConfig := &tls.Config{InsecureSkipVerify: true} //nolint:gosec
		http_helper.HttpGetWithRetryWithCustomValidation(
			t,
			serverURL,
			tlsConfig,
			30,
			10*time.Second,
			func(statusCode int, body string) bool {
				return statusCode == 200 && strings.Contains(body, "Rundeck")
			},
		)
	})

	t.Run("tls_certificate_present", func(t *testing.T) {
		tlsConfig := &tls.Config{InsecureSkipVerify: true} //nolint:gosec
		conn, err := tls.Dial("tcp", publicIP+":443", tlsConfig)
		require.NoError(t, err)
		defer func() { _ = conn.Close() }()
		certs := conn.ConnectionState().PeerCertificates
		assert.Greater(t, len(certs), 0, "Expected at least one TLS certificate")
	})

	t.Run("rundeck_login_functional", func(t *testing.T) {
		tlsConfig := &tls.Config{InsecureSkipVerify: true} //nolint:gosec
		// Rundeck login page returns 200 and contains a login form
		http_helper.HttpGetWithRetryWithCustomValidation(
			t,
			serverURL+"/user/login",
			tlsConfig,
			10,
			5*time.Second,
			func(statusCode int, body string) bool {
				return statusCode == 200 && strings.Contains(body, "login")
			},
		)
	})

	t.Run("postgresql_accepting_connections", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "sudo -u postgres /usr/pgsql-16/bin/pg_isready -h localhost -p 5432")
		require.NoError(t, err)
		assert.Contains(t, result, "accepting connections")
	})

	// --- Infrastructure checks ---

	t.Run("selinux_enforcing", func(t *testing.T) {
		result, err := ssh.CheckSshCommandE(t, host, "getenforce")
		require.NoError(t, err)
		assert.Contains(t, result, "Enforcing")
	})

	t.Run("cloudwatch_log_group_configured", func(t *testing.T) {
		logGroupName := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")
		require.NotEmpty(t, logGroupName)
		// Verify the CloudWatch agent config on the instance references the correct log group
		result, err := ssh.CheckSshCommandE(t, host,
			"sudo cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json 2>/dev/null || sudo cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml 2>/dev/null || echo NOT_FOUND")
		require.NoError(t, err)
		assert.Contains(t, result, logGroupName, "CloudWatch agent config should reference the log group")
	})
}
