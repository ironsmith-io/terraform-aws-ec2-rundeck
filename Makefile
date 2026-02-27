# Makefile for Rundeck Terraform module

# Example directory: override with EXAMPLE=minimal or EXAMPLE=ssm-only
EXAMPLE  ?= complete
EXAMPLE_DIR = examples/$(EXAMPLE)
KEY_NAME ?= rundeck-us-west-2

# SSH key for make ssh/cloud-init/rundeck-log/status (optional, see .envrc.example)
SSH_KEY := $(if $(TEST_PRIVATE_KEY_PATH),-i $(TEST_PRIVATE_KEY_PATH),)

# Terminal colors (graceful degradation for non-interactive shells)
GREEN  := $(shell tput -Txterm setaf 2 2>/dev/null)
YELLOW := $(shell tput -Txterm setaf 3 2>/dev/null)
CYAN   := $(shell tput -Txterm setaf 6 2>/dev/null)
RESET  := $(shell tput -Txterm sgr0 2>/dev/null)

.DEFAULT_GOAL := help

.PHONY: help init plan apply destroy pre-commit reset ssh ssm open \
	dashboard logs cloud-init rundeck-log status output \
	test test-unit test-integration test-all test-setup \
	clean setup keygen keyclean

help:
	@echo "$(CYAN)Rundeck Terraform Module$(RESET)"
	@echo ""
	@echo "  Override example:  make plan EXAMPLE=ssm-only"
	@echo "  Available:         complete (default), minimal, ssm-only"
	@echo ""
	@echo "$(YELLOW)Terraform:$(RESET)"
	@echo "  $(GREEN)init$(RESET)        - Initialize terraform"
	@echo "  $(GREEN)plan$(RESET)        - Run terraform plan"
	@echo "  $(GREEN)apply$(RESET)       - Run terraform apply with auto-approve"
	@echo "  $(GREEN)destroy$(RESET)     - Run terraform destroy with auto-approve"
	@echo "  $(GREEN)reset$(RESET)       - Destroy and then apply terraform (full reset)"
	@echo "  $(GREEN)output$(RESET)      - Show terraform outputs"
	@echo ""
	@echo "$(YELLOW)Access:$(RESET)"
	@echo "  $(GREEN)ssh$(RESET)         - SSH into the EC2 instance"
	@echo "  $(GREEN)ssm$(RESET)         - Connect via SSM Session Manager"
	@echo "  $(GREEN)open$(RESET)        - Open Rundeck UI in browser"
	@echo ""
	@echo "$(YELLOW)CloudWatch:$(RESET)"
	@echo "  $(GREEN)dashboard$(RESET)   - Open CloudWatch dashboard in browser"
	@echo "  $(GREEN)logs$(RESET)        - Tail CloudWatch logs in terminal"
	@echo ""
	@echo "$(YELLOW)Debug:$(RESET)"
	@echo "  $(GREEN)cloud-init$(RESET)  - View cloud-init output log"
	@echo "  $(GREEN)rundeck-log$(RESET) - View Rundeck service log"
	@echo "  $(GREEN)status$(RESET)      - Check service status"
	@echo ""
	@echo "$(YELLOW)Testing:$(RESET)"
	@echo "  $(GREEN)test$(RESET)              - Run static analysis and unit tests (fast, no AWS)"
	@echo "  $(GREEN)test-unit$(RESET)         - Run terraform test unit tests"
	@echo "  $(GREEN)test-integration$(RESET)  - Run Terratest integration tests (deploys resources)"
	@echo "  $(GREEN)test-all$(RESET)          - Run all tests"
	@echo ""
	@echo "$(YELLOW)Development:$(RESET)"
	@echo "  $(GREEN)setup$(RESET)       - Check prerequisites and bootstrap dev environment"
	@echo "  $(GREEN)keygen$(RESET)      - Create AWS key pair and save private key (KEY_NAME=$(KEY_NAME))"
	@echo "  $(GREEN)keyclean$(RESET)    - Delete AWS key pair and private key (KEY_NAME=$(KEY_NAME))"
	@echo ""
	@echo "$(YELLOW)Code quality:$(RESET)"
	@echo "  $(GREEN)pre-commit$(RESET)  - Run all checks (fmt, validate, docs, lint, security)"
	@echo "  $(GREEN)clean$(RESET)       - Remove .terraform cache from example dir (safe, re-run init)"

#=============================================================================
# Development setup
#=============================================================================

setup:
	@echo "$(CYAN)Checking prerequisites...$(RESET)"
	@command -v terraform >/dev/null 2>&1 || { echo "$(YELLOW)ERROR: terraform not found$(RESET)"; exit 1; }
	@command -v go >/dev/null 2>&1 || { echo "$(YELLOW)WARNING: go not found (needed for integration tests)$(RESET)"; }
	@command -v pre-commit >/dev/null 2>&1 || { echo "$(YELLOW)WARNING: pre-commit not found - install with: pip install pre-commit$(RESET)"; }
	@command -v direnv >/dev/null 2>&1 || { echo "$(YELLOW)WARNING: direnv not found - install with: brew install direnv$(RESET)"; }
	@if [ ! -f .envrc ]; then \
		cp .envrc.example .envrc; \
		echo "$(GREEN)Created .envrc from template - edit with your values$(RESET)"; \
	else \
		echo ".envrc already exists"; \
	fi
	@pre-commit install 2>/dev/null && echo "$(GREEN)pre-commit hooks installed$(RESET)" || true
	@echo "$(GREEN)Setup complete.$(RESET) Edit .envrc with your values, then run: direnv allow"

keygen:
	@if [ -f "$(KEY_NAME).pem" ]; then echo "Key $(KEY_NAME).pem already exists. Run 'make keyclean' first or use KEY_NAME=other-name"; exit 1; fi
	@echo "Creating AWS key pair '$(KEY_NAME)'..."
	@aws ec2 create-key-pair --key-name $(KEY_NAME) --key-type ed25519 --query 'KeyMaterial' --output text > $(KEY_NAME).pem
	@chmod 600 $(KEY_NAME).pem
	@echo "$(GREEN)Created AWS key pair '$(KEY_NAME)' and saved private key to $(KEY_NAME).pem$(RESET)"
	@echo ""
	@echo "Add to your .envrc:"
	@echo "  export TEST_PRIVATE_KEY_PATH=\$$PWD/$(KEY_NAME).pem"
	@echo ""
	@echo "Then set key_pair_name in your terraform.tfvars:"
	@echo "  key_pair_name = \"$(KEY_NAME)\""

keyclean:
	@if [ ! -f "$(KEY_NAME).pem" ]; then echo "No key $(KEY_NAME).pem found"; exit 1; fi
	@echo "Deleting AWS key pair '$(KEY_NAME)'..."
	@aws ec2 delete-key-pair --key-name $(KEY_NAME)
	@rm -f $(KEY_NAME).pem
	@echo "$(GREEN)Deleted AWS key pair '$(KEY_NAME)' and removed $(KEY_NAME).pem$(RESET)"

#=============================================================================
# Terraform targets
#=============================================================================

init:
	cd $(EXAMPLE_DIR) && terraform init

plan:
	cd $(EXAMPLE_DIR) && terraform plan

output:
	cd $(EXAMPLE_DIR) && terraform output

apply:
	@echo "$(YELLOW)>>> $(EXAMPLE_DIR)$(RESET)"
	cd $(EXAMPLE_DIR) && terraform apply --auto-approve

destroy:
	@echo "$(YELLOW)>>> $(EXAMPLE_DIR)$(RESET)"
	cd $(EXAMPLE_DIR) && terraform destroy --auto-approve

pre-commit:
	pre-commit run --all-files

clean:
	cd $(EXAMPLE_DIR) && rm -rf .terraform

reset: destroy
	@echo "$(YELLOW)>>> $(EXAMPLE_DIR)$(RESET)"
	cd $(EXAMPLE_DIR) && terraform apply --auto-approve

#=============================================================================
# Access targets
#=============================================================================

ssh:
	ssh $(SSH_KEY) rocky@$$(cd $(EXAMPLE_DIR) && terraform output -raw public_ip)

ssm:
	aws ssm start-session --target $$(cd $(EXAMPLE_DIR) && terraform output -raw instance_id)

open:
	@IP=$$(cd $(EXAMPLE_DIR) && terraform output -raw public_ip); \
	case "$$(uname)" in \
		"Darwin") open "https://$$IP" ;; \
		"Linux") xdg-open "https://$$IP" ;; \
		*) echo "Open https://$$IP" ;; \
	esac

#=============================================================================
# CloudWatch targets
#=============================================================================

dashboard:
	@URL=$$(cd $(EXAMPLE_DIR) && terraform output -raw cloudwatch_dashboard_url 2>/dev/null); \
	if [ -z "$$URL" ] || [ "$$URL" = "null" ]; then \
		echo "CloudWatch not enabled. Set enable_cloudwatch_logs = true"; \
	else \
		case "$$(uname)" in \
			"Darwin") open "$$URL" ;; \
			"Linux") xdg-open "$$URL" ;; \
			*) echo "Open $$URL" ;; \
		esac \
	fi

logs:
	@LOG_GROUP=$$(cd $(EXAMPLE_DIR) && terraform output -raw cloudwatch_log_group_name 2>/dev/null); \
	if [ -z "$$LOG_GROUP" ] || [ "$$LOG_GROUP" = "null" ]; then \
		echo "CloudWatch not enabled. Set enable_cloudwatch_logs = true"; \
	else \
		aws logs tail "$$LOG_GROUP" --follow; \
	fi

#=============================================================================
# Debug targets
#=============================================================================

cloud-init:
	ssh $(SSH_KEY) rocky@$$(cd $(EXAMPLE_DIR) && terraform output -raw public_ip) "sudo tail -100 /var/log/cloud-init-output.log"

rundeck-log:
	ssh $(SSH_KEY) rocky@$$(cd $(EXAMPLE_DIR) && terraform output -raw public_ip) "sudo tail -100 /var/log/rundeck/service.log"

status:
	ssh $(SSH_KEY) rocky@$$(cd $(EXAMPLE_DIR) && terraform output -raw public_ip) "sudo systemctl status nginx rundeckd postgresql-16 --no-pager"

#=============================================================================
# Testing targets
#=============================================================================

test: pre-commit test-unit
	@echo "Static analysis and unit tests passed"

test-unit:
	@echo "Running terraform test (unit tests)..."
	terraform init -backend=false
	terraform test -filter=tests/unit.tftest.hcl

test-integration: test-setup
	@echo "Running Terratest integration tests..."
	@echo "WARNING: This will deploy real AWS resources and incur costs"
	@if [ -z "$$TEST_SUBNET_ID" ]; then echo "ERROR: TEST_SUBNET_ID not set"; exit 1; fi
	cd test && go test -v -timeout 30m -run TestRundeck

test-all: test test-integration
	@echo "All tests passed"

test-setup:
	@echo "Setting up Terratest dependencies..."
	cd test && go mod tidy && go mod download
