# 202603-ec2-mac-efs-fsx

AWS infrastructure provisioning with Terraform.
Manages EC2 (Mac / I4i), EFS, FSx for Windows, FSx for OpenZFS, Amazon WorkSpaces, and related resources.

## Architecture

Terraform configuration is split into two layers:

| Layer | Path | Resources |
|---|---|---|
| Persistent | `iac/aws/` | VPC, subnets, internet gateway, route tables |
| Ephemeral | `iac/aws/ephemeral/` | EFS, FSx (Windows / OpenZFS), EC2 (I4i / Mac), WorkSpaces, Managed Microsoft AD |

The ephemeral layer references the persistent layer via Terraform remote state and can be created or destroyed independently.

## Prerequisites

- Docker Engine + Docker Compose (e.g. [Docker Desktop](https://www.docker.com/products/docker-desktop/), [Colima](https://github.com/abiosoft/colima))
- AWS CLI installed on the host

## Quick Start

```sh
cp .example.env .env
cp .example.secrets.env .secrets.env
# Edit .env and .secrets.env with your AWS settings
```

### Running Terraform locally

```sh
docker compose run --rm iac sh
# Inside the container:
cd iac/aws
terraform init -backend-config="bucket=<your-bucket>" -backend-config="region=<your-region>"
terraform plan
terraform apply
```

## Project Structure

```
.
├── compose.yaml                  # Docker Compose (Terraform runner)
├── .example.env                  # Environment variable template
├── .example.secrets.env          # Secrets template (AD password, etc.)
├── Dockerfiles.d/
│   └── iac/Dockerfile            # Terraform container
├── iac/
│   └── aws/
│       ├── vpc-network.tf        # VPC & subnets (persistent)
│       ├── variables.tf
│       ├── outputs.tf
│       └── ephemeral/
│           ├── efs.tf            # Amazon EFS
│           ├── fsx-windows.tf    # FSx for Windows
│           ├── fsx-openzfs.tf    # FSx for OpenZFS
│           ├── ec2-i4i.tf        # EC2 I4i (storage-optimized)
│           ├── ec2-mac.tf        # EC2 Mac (dedicated host)
│           ├── workspaces.tf     # Amazon WorkSpaces (Linux)
│           ├── directory-service.tf  # AWS Managed Microsoft AD
│           ├── remote-state.tf   # Persistent layer state reference
│           ├── variables.tf
│           └── outputs.tf
├── .github/
│   ├── workflows/
│   │   ├── iac.yaml              # Persistent layer CI
│   │   ├── iac.ephemeral.yaml    # Ephemeral layer CI (plan/apply/destroy)
│   │   └── _reusable-iac.yaml   # Reusable workflow
│   └── actions/
│       └── bootstrap-tfstate-s3/ # S3 tfstate bucket bootstrap
└── docs/
    ├── cloud-deployment.md       # Architecture overview
    ├── cloud-deployment-aws.md   # AWS deployment guide
    ├── ci.md                     # GitHub Actions configuration
    └── oidc-setup.md             # OIDC authentication setup
```

## GitHub Actions

| Workflow | Trigger | Purpose |
|---|---|---|
| `iac.yaml` | push / PR to main | Persistent layer plan & apply |
| `iac.ephemeral.yaml` | workflow_dispatch | Ephemeral layer plan / apply / destroy |

Workflows authenticate to AWS via OIDC. See [OIDC Setup](docs/oidc-setup.md) for details.

## Documentation

- [Cloud Deployment (AWS)](docs/cloud-deployment-aws.md) — Manual deployment with Terraform
- [Cloud Deployment Overview](docs/cloud-deployment.md) — Persistent + ephemeral layer architecture
- [CI / GitHub Actions](docs/ci.md) — Workflows and required variables
- [OIDC Setup](docs/oidc-setup.md) — AWS OIDC authentication for GitHub Actions
