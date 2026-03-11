# 202603-ec2-mac-efs-fsx

Terraform を使用した AWS インフラストラクチャのプロビジョニング。
EC2（Mac / I4i）、EFS、FSx for Windows、FSx for OpenZFS、Amazon WorkSpaces、および関連リソースを管理します。

## アーキテクチャ

Terraform の構成は2つのレイヤーに分かれています：

| レイヤー | パス | リソース |
|---|---|---|
| 永続 | `iac/aws/` | VPC、サブネット、インターネットゲートウェイ、ルートテーブル |
| エフェメラル | `iac/aws/ephemeral/` | EFS、FSx（Windows / OpenZFS）、EC2（I4i / Mac）、WorkSpaces、Managed Microsoft AD |

エフェメラルレイヤーは Terraform リモートステートを介して永続レイヤーを参照し、独立して作成・削除できます。

## 前提条件

- Docker Engine + Docker Compose（例: [Docker Desktop](https://www.docker.com/products/docker-desktop/)、[Colima](https://github.com/abiosoft/colima)）
- ホストに AWS CLI がインストール済みであること

## クイックスタート

```sh
cp .example.env .env
cp .example.secrets.env .secrets.env
# .env と .secrets.env を AWS の設定に合わせて編集
```

### ローカルで Terraform を実行する

```sh
docker compose run --rm iac sh
# コンテナ内で:
cd iac/aws
terraform init -backend-config="bucket=<your-bucket>" -backend-config="region=<your-region>"
terraform plan
terraform apply
```

## プロジェクト構造

```
.
├── compose.yaml                  # Docker Compose（Terraform 実行環境）
├── .example.env                  # 環境変数テンプレート
├── .example.secrets.env          # シークレットテンプレート（AD パスワード等）
├── Dockerfiles.d/
│   └── iac/Dockerfile            # Terraform コンテナ
├── iac/
│   └── aws/
│       ├── vpc-network.tf        # VPC & サブネット（永続）
│       ├── variables.tf
│       ├── outputs.tf
│       └── ephemeral/
│           ├── efs.tf            # Amazon EFS
│           ├── fsx-windows.tf    # FSx for Windows
│           ├── fsx-openzfs.tf    # FSx for OpenZFS
│           ├── ec2-i4i.tf        # EC2 I4i（ストレージ最適化）
│           ├── ec2-mac.tf        # EC2 Mac（専有ホスト）
│           ├── workspaces.tf     # Amazon WorkSpaces（Linux）
│           ├── directory-service.tf  # AWS Managed Microsoft AD
│           ├── remote-state.tf   # 永続レイヤーのステート参照
│           ├── variables.tf
│           └── outputs.tf
├── .github/
│   ├── workflows/
│   │   ├── iac.yaml              # 永続レイヤー CI
│   │   ├── iac.ephemeral.yaml    # エフェメラルレイヤー CI（plan/apply/destroy）
│   │   └── _reusable-iac.yaml   # 再利用可能ワークフロー
│   └── actions/
│       └── bootstrap-tfstate-s3/ # S3 tfstate バケットのブートストラップ
└── docs/
    ├── cloud-deployment.md       # アーキテクチャ概要
    ├── cloud-deployment-aws.md   # AWS デプロイガイド
    ├── ci.md                     # GitHub Actions 設定
    └── oidc-setup.md             # OIDC 認証セットアップ
```

## GitHub Actions

| ワークフロー | トリガー | 目的 |
|---|---|---|
| `iac.yaml` | main への push / PR | 永続レイヤーの plan & apply |
| `iac.ephemeral.yaml` | workflow_dispatch | エフェメラルレイヤーの plan / apply / destroy |

ワークフローは OIDC を使用して AWS に認証します。詳細は [OIDC セットアップ](docs/oidc-setup.ja.md) を参照してください。

## ドキュメント

- [クラウドデプロイ（AWS）](docs/cloud-deployment-aws.ja.md) — Terraform による手動デプロイ
- [クラウドデプロイ概要](docs/cloud-deployment.ja.md) — 永続 + エフェメラルレイヤーのアーキテクチャ
- [CI / GitHub Actions](docs/ci.ja.md) — ワークフローと必要な変数
- [OIDC セットアップ](docs/oidc-setup.ja.md) — GitHub Actions 向け AWS OIDC 認証
