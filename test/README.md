# Testing Guide

## Testing Pyramid

```
                    ┌─────────────────┐
                    │   Integration   │  ← Terratest (nightly/weekly)
                    │                 │
                    ├─────────────────┤
                    │   Unit/Contract │  ← terraform test (every PR)
                    │                 │
                    ├─────────────────┤
                    │   Static        │  ← pre-commit (every commit)
                    │ (fmt/validate)  │
                    └─────────────────┘
```

## Quick Start

```bash
# Static analysis (fast, no AWS)
make pre-commit

# Unit tests (fast, no AWS)
make test-unit

# Integration tests (deploys real resources)
make test-integration

# All tests
make test-all
```

## Test Levels

### Level 1: Static Analysis (Every Commit)

**Tools:** pre-commit hooks (terraform fmt, validate, tflint, checkov, gitleaks)

```bash
make pre-commit
```

**Cost:** Free, ~30 seconds

### Level 2: Unit Tests (Every PR)

**Tools:** `terraform test` with mock providers

**What it validates:**
- Variable validation rules (subnet_id format, CIDR blocks, instance types)
- Conditional resource logic
- Input/output contracts

```bash
make test-unit
```

**Cost:** Free, ~30 seconds

**Files:** `tests/unit.tftest.hcl`

### Level 3: Integration Tests (Nightly/Weekly)

**Tools:** Terratest (Go)

**What it validates:**
- Resources deploy successfully
- Services are running (Rundeck, nginx, PostgreSQL)
- HTTPS endpoint is accessible
- CloudWatch and SSM agents are running

**Prerequisites:**
```bash
export TEST_SUBNET_ID="subnet-xxxxxxxx"
```

The test generates its own ephemeral EC2 key pair via `aws.CreateAndImportEC2KeyPair()` and cleans it up automatically.

```bash
make test-integration
```

**Cost:** ~$0.50-2.00 per run, 15-30 minutes

**Files:** `test/rundeck_test.go`

## Test Matrix

| Test | Command | Blocks PR | AWS Cost | Time |
|------|---------|-----------|----------|------|
| Static analysis | `make pre-commit` | Yes | $0 | 30s |
| Unit tests | `make test-unit` | Yes | $0 | 30s |
| Integration | `make test-integration` | No | ~$1 | 20m |
| All tests | `make test-all` | No | ~$1 | 25m |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TEST_SUBNET_ID` | Yes | VPC subnet for test instances |

SSH key pairs are generated automatically by the test. Use `.envrc` with direnv to set `TEST_SUBNET_ID`. See `.envrc.example`.

## Troubleshooting

### Terratest fails with "go mod" errors

```bash
cd test && go mod tidy && go mod download
```

### terraform test fails with provider errors

```bash
terraform init -backend=false
terraform test
```

### Integration tests timeout

```bash
cd test && go test -v -timeout 60m -run TestRundeck
```
