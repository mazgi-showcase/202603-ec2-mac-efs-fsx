# CI / GitHub Actions

## Workflows

### IaC (Terraform)

| Workflow | Description |
|----------|-------------|
| `iac.yaml` | Persistent layer: PR = plan, push to main = apply. |
| `iac.ephemeral.yaml` | Ephemeral layer: manual dispatch (plan/apply/destroy). |

## Env file naming convention

| File | Purpose |
|------|---------|
| `.example.env` / `.example.secrets.env` | Templates (committed to repo) |
| `.env` / `.secrets.env` | Local development |

## Setup

1. **Variables** — `cp .example.env .env`, edit, then upload:

   ```sh
   gh variable set --env-file .env
   ```

2. **Secrets** — `cp .example.secrets.env .secrets.env`, edit, then upload:

   ```sh
   gh secret set --env-file .secrets.env
   ```

3. **OIDC auth** — see [OIDC Setup](oidc-setup.md)

### Reset variables/secrets

```sh
gh variable list --json name --jq '.[].name' | xargs -I {} gh variable delete {}
gh secret list --json name --jq '.[].name' | xargs -I {} gh secret delete {}
```

## Required Variables

### Terraform state backend

| Variable | Example |
|----------|---------|
| `AWS_TF_STATE_BUCKET` | `my-tf-state-bucket` |
| `AWS_TF_STATE_REGION` | `us-east-1` |

### AWS identifiers

| Variable | Example |
|----------|---------|
| `AWS_IAM_ROLE_ARN` | `arn:aws:iam::123456789012:role/github-actions-iac` |
| `TF_VAR_app_unique_id` | `my-infra` |
| `TF_VAR_aws_region` | `us-east-1` |
| `TF_VAR_ec2_mac_availability_zone_id` | `use1-az4` |
| `TF_VAR_workspace_bundle_id` | `wsb-xnp4cfzht` |

## Required Secrets

| Secret | Description |
|--------|-------------|
| `TF_VAR_ad_admin_password` | Managed Microsoft AD admin password |
