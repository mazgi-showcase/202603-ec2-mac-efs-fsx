# AWS Deployment

See [Cloud Deployment](cloud-deployment.md) for architecture overview.

## Prerequisites

- An AWS account with appropriate permissions
- AWS CLI installed on the host
- Docker Engine + Docker Compose running (Terraform runs inside a container)

### Authenticate with AWS on the host

The `iac` container mounts `~/.aws` as read-only, so credentials configured on the host are automatically available inside the container.

**Option A — Long-lived credentials (IAM user)**

```sh
aws configure
```

**Option B — SSO / Identity Center**

```sh
aws configure sso
aws sso login --profile YOUR_PROFILE
```

When using an SSO profile, set the `AWS_PROFILE` environment variable:

```sh
export AWS_PROFILE=YOUR_PROFILE
```

Or add `AWS_PROFILE` to your `.secrets.env` file — the `iac` service loads it via `env_file`.

**Verify**

```sh
aws sts get-caller-identity
```

## 1. Create the Terraform state bucket

```sh
aws s3api create-bucket --bucket YOUR_BUCKET_NAME --region us-east-1
aws s3api put-bucket-versioning --bucket YOUR_BUCKET_NAME \
  --versioning-configuration Status=Enabled
```

The bucket name is passed via `-backend-config` at `terraform init` time (see step 3).

## 2. Configure variables

```sh
cp .example.env .env
cp .example.secrets.env .secrets.env
```

Edit `.env`:

- `TF_VAR_app_unique_id` — unique prefix for resource names
- `TF_VAR_ec2_mac_availability_zone_id` — AZ ID for the Mac dedicated host (e.g. `use1-az4`)
- `TF_VAR_workspace_bundle_id` — WorkSpaces bundle ID (find with `aws workspaces describe-workspace-bundles --owner AMAZON`)

Edit `.secrets.env`:

- `TF_VAR_ad_admin_password` — password for the Managed Microsoft AD admin user

## 3. Create persistent infrastructure

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws apply
```

## 4. Deploy ephemeral infrastructure

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral apply
```

## 5. Tear down (after testing)

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral destroy
```

> **Note:** Some resources (e.g. FSx Windows file systems, Directory Service) may take a while to delete due to dependencies. If `destroy` fails on the first attempt, wait a few minutes and re-run the command.

## Resources created

| Layer | Resource | Description |
|-------|----------|-------------|
| Persistent | VPC | Custom VPC with public + private subnets across 2 AZs |
| Persistent | Internet Gateway | Public subnet internet access |
| Ephemeral | Managed Microsoft AD | Directory for WorkSpaces and FSx Windows |
| Ephemeral | Amazon EFS | Elastic File System |
| Ephemeral | FSx for Windows | Windows file server backed by AD |
| Ephemeral | FSx for OpenZFS | ZFS-based file system |
| Ephemeral | EC2 I4i | Storage-optimized instance |
| Ephemeral | EC2 Mac | Mac dedicated host + instance |
| Ephemeral | Amazon WorkSpaces | Linux workspace (Ubuntu) |
