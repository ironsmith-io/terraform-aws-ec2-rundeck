# Security Policy

## Supported Versions

Security fixes are provided for the latest published `1.x` release. Older
tags are not maintained — please upgrade to the newest `1.x` version before
reporting an issue.

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

Please report suspected security vulnerabilities **privately** through GitHub's
[Private vulnerability reporting](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/security/advisories/new)
(the repository's **Security → Advisories → "Report a vulnerability"** button).

**Do not open a public issue or pull request for security problems.**

When reporting, please include as much of the following as you can:

- A description of the vulnerability and its potential impact
- Steps to reproduce, or a proof of concept
- The module version and a minimal Terraform configuration that triggers it
- Any known workarounds

### What to expect

This is a community-maintained module, so responses are best-effort:

- Acknowledgement of your report, typically within a few business days
- An assessment of severity and affected versions
- A fix released in a new `1.x` version, credited to you unless you prefer otherwise

## Scope

This module provisions AWS infrastructure (EC2, security groups, IAM, and
related resources). Some documented defaults are intended for convenience in
development and are **not** considered vulnerabilities on their own, for example:

- Default Rundeck credentials (`admin`/`admin`) — change these before production use
- A self-signed TLS certificate fallback when no domain is configured
- Example configurations that open ports to `0.0.0.0/0`

Reports about the module generating insecure configuration by default, escalating
privileges unexpectedly, or exposing secrets are in scope and welcome.
