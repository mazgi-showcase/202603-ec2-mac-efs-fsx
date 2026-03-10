# Cloud Deployment

Deploy AWS infrastructure with Terraform.

## Deployment methods

- **Manual (Terraform CLI)** — Follow [AWS deployment guide](cloud-deployment-aws.md)
- **CI/CD (GitHub Actions)** — Automate via GitHub Actions. See [CI / GitHub Actions](ci.md)

## Architecture: persistent + ephemeral layers

Two Terraform layers:

- **Persistent** (`iac/aws/`) — VPC, subnets. Low cost. Always running.
- **Ephemeral** (`iac/aws/ephemeral/`) — EFS, FSx, EC2, WorkSpaces, etc. Create for testing, destroy when done.

Each ephemeral layer reads outputs from its persistent layer via `terraform_remote_state` (see `remote-state.tf`).

## Terraform commands

All commands run via Docker Compose with `-chdir` to select the layer. The `init` command requires `-backend-config` to inject the state backend location:

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws apply

docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral apply
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral destroy
```
