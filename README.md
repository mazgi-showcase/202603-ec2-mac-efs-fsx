# template.containerized-provisioning-project

[![use-multiple-platforms](https://github.com/mazgi/template.containerized-provisioning-project/actions/workflows/use-multiple-platforms.yml/badge.svg)](https://github.com/mazgi/template.containerized-provisioning-project/actions/workflows/use-multiple-platforms.yml)
[![use-one-platform](https://github.com/mazgi/template.containerized-provisioning-project/actions/workflows/use-one-platform.yml/badge.svg)](https://github.com/mazgi/template.containerized-provisioning-project/actions/workflows/use-one-platform.yml)

This repository is a template for provisioning your Cloud and Local environment using [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/).

## How to Use

<u>Docker and [Docker Compose](https://docs.docker.com/compose/)</u> are needed. If you want to provision only local environments, that's all.

However, if you want to provision a cloud environment, you need permission that can administer for at least one cloud: [AWS](https://aws.amazon.com/), [Azure](https://azure.microsoft.com/), or [Google Cloud](https://cloud.google.com/).  
And you need to set up the repository following steps.

### Step 1. Write out your IDs and credentials in the .env file.

You should write your account IDs and credentials depending on your need, such as AWS, Azure, and Google Cloud, in the `.env` file as follows.

```.env
# UID=1234
# GID=1234
# DOCKER_GID=2345
PROJECT_UNIQUE_ID=my-unique-b78e
_TERRAFORM_BACKEND_TYPE=azurerm
TF_VAR_allowed_ipaddr_list=["203.0.113.0/24"]
#
# <AWS>
AWS_ACCESS_KEY_ID=AKXXXXXXXX
AWS_ACCOUNT_ID=123456789012
# AWS_DEFAULT_REGION=us-east-1
AWS_SECRET_ACCESS_KEY=AWxxxxxxxx00000000
# </AWS>
#
# <Azure>
# AZURE_DEFAULT_LOCATION=centralus
ARM_CLIENT_ID=xxxxxxxx-0000-0000-0000-xxxxxxxxxxxx
ARM_CLIENT_SECRET=********
ARM_SUBSCRIPTION_ID=yyyyyyyy-0000-0000-0000-yyyyyyyyyyyy
ARM_TENANT_ID=zzzzzzzz-0000-0000-0000-zzzzzzzzzzzz
# </Azure>
#
# <Google>
# GCP_DEFAULT_REGION=us-central1
CLOUDSDK_CORE_PROJECT=my-proj-b78e
# </Google>
```

:information_source: If you are using Linux, write out UID, GID, and GID for the `docker` group, into the `.env` file to let that as exported on Docker Compose as environment variables.

```console
test $(uname -s) = 'Linux' && {
  echo -e "DOCKER_GID=$(getent group docker | cut -d : -f 3)"
  echo -e "GID=$(id -g)"
  echo -e "UID=$(id -u)"
} >> .env || :
```

:information_source: In addition, if you use Google Cloud, you should place the [key file for Google Cloud Service Account](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) as `config/credentials/google-cloud-keyfile.provisioning-owner.json`.

#### Environment Variable Names

Environment variable names and uses are as follows.

| Name       | Required on Linux | Value                                                                                                                                   |
| ---------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| UID        | **Yes**           | This ID number is used as UID for your Docker user, so this ID becomes the owner of all files and directories created by the container. |
| GID        | **Yes**           | The same as the above UID.                                                                                                              |
| DOCKER_GID | **Yes**           | This ID number is used to provide permission to read and write your docker socket on your local machine from your container.            |

| Name                       | Required with Terraform | Value                                                                                                                                         |
| -------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| PROJECT_UNIQUE_ID          | **Yes**                 | An ID to indicate your environment.<br/>The value is used for the name of the Object Storage bucket or Storage Account for Terraform backend. |
| \_TERRAFORM_BACKEND_TYPE   | **Yes**                 | Acceptable values are `azurerm`, `gcs`, `s3`, and `none`.                                                                                     |
| TF_VAR_allowed_ipaddr_list | no                      | IP address ranges you want access to your cloud environment.                                                                                  |

</details>
<details>
<summary>AWS</summary>

| Name                  | Required with AWS | Value                                                                                                                                                 |
| --------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| AWS_ACCOUNT_ID        | **Yes**           | A 12-digit AWS Account ID you want to provision.<br/>The S3 bucket is created in this account to store the tfstate file if you choose the S3 backend. |
| AWS_ACCESS_KEY_ID     | **Yes**           | An AWS Access Key for the IAM user that is used to create the S3 bucket to store tfstate file and apply all in your AWS environment.                  |
| AWS_SECRET_ACCESS_KEY | **Yes**           |                                                                                                                                                       |
| AWS_DEFAULT_REGION    | no                |                                                                                                                                                       |

</details>
<details>
<summary>
Azure

You are able to generate Azure Service Principal according to the [how-to-create-azure-service-principal.md](docs/how-to-create-azure-service-principal.md).

</summary>

| Name                   | Required with Azure | Value                                                                                                                                                                                                                  |
| ---------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ARM_TENANT_ID          | **Yes**             | A UUID to indicate Azure Tenant.                                                                                                                                                                                       |
| ARM_SUBSCRIPTION_ID    | **Yes**             | A UUID to indicate Azure Subscription you want to provision.<br/>The Resource Group, Storage Account, and Blob Container are created in this subscription to store the tfstate file if you choose the AzureRM backend. |
| ARM_CLIENT_ID          | **Yes**             |                                                                                                                                                                                                                        |
| ARM_CLIENT_SECRET      | **Yes**             |                                                                                                                                                                                                                        |
| AZURE_DEFAULT_LOCATION | no                  |                                                                                                                                                                                                                        |

</details>
<details>
<summary>Google Cloud</summary>

| Name                  | Required with Azure | Value                                                                                                                                                                                                                                                                                                                   |
| --------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CLOUDSDK_CORE_PROJECT | **Yes**             | A string Project ID to indicate Google Cloud Project you want to provision, Not Project name or Project number.<br/>The Cloud Storage Bucket is created in this project to store the tfstate file if you choose the GCS backend.<br/>See also https://cloud.google.com/resource-manager/docs/creating-managing-projects |
| GCP_DEFAULT_REGION    | no                  |                                                                                                                                                                                                                                                                                                                         |

</details>

### Step 2. Define your service in the `docker-compose.yml`

You are able to update and define the `provisioning` service to your need in the [`docker-compose.yml`](docker-compose.yml).

```yaml
services:
  provisioning:
    <<: *provisioning-base
```

Make sure your config.

```console
docker compose config
```

Now, you are able to provision your environment as follows. :tada:

```console
docker compose build
```

```console
docker compose up
```

```console
docker compose exec provisioning terraform apply
```

```console
docker compose down
```

### Step 3. Set secrets for GitHub Actions

The [gh command](https://cli.github.com/) helps set secrets.

```console
gh secret set --app actions --env-file .env
```

```console
cat config/credentials/google-cloud-keyfile.provisioning-owner.json\
 | gh secret set GOOGLE_SA_KEY --app=actions
```
