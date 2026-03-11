# AWS デプロイ

アーキテクチャの概要は [クラウドデプロイ](cloud-deployment.ja.md) を参照してください。

## 前提条件

- 適切な権限を持つ AWS アカウント
- ホストに AWS CLI がインストール済みであること
- Docker Engine + Docker Compose が稼働していること（Terraform はコンテナ内で実行されます）

### ホストで AWS 認証を行う

`iac` コンテナは `~/.aws` を読み取り専用でマウントするため、ホストで設定した認証情報がコンテナ内で自動的に利用可能になります。

**方法 A — 長期認証情報（IAM ユーザー）**

```sh
aws configure
```

**方法 B — SSO / Identity Center**

```sh
aws configure sso
aws sso login --profile YOUR_PROFILE
```

SSO プロファイルを使用する場合は、`AWS_PROFILE` 環境変数を設定します：

```sh
export AWS_PROFILE=YOUR_PROFILE
```

または `.secrets.env` ファイルに `AWS_PROFILE` を追加します — `iac` サービスは `env_file` 経由でこのファイルを読み込みます。

**確認**

```sh
aws sts get-caller-identity
```

## 1. Terraform ステートバケットの作成

```sh
aws s3api create-bucket --bucket YOUR_BUCKET_NAME --region us-east-1
aws s3api put-bucket-versioning --bucket YOUR_BUCKET_NAME \
  --versioning-configuration Status=Enabled
```

バケット名は `terraform init` 時に `-backend-config` で渡します（手順3を参照）。

## 2. 変数の設定

```sh
cp .example.env .env
cp .example.secrets.env .secrets.env
```

`.env` を編集：

- `TF_VAR_app_unique_id` — リソース名の一意なプレフィックス
- `TF_VAR_ec2_mac_availability_zone_id` — Mac 専有ホストの AZ ID（例: `use1-az4`）
- `TF_VAR_workspace_bundle_id` — WorkSpaces バンドル ID（`aws workspaces describe-workspace-bundles --owner AMAZON` で確認可能）

`.secrets.env` を編集：

- `TF_VAR_ad_admin_password` — Managed Microsoft AD 管理者ユーザーのパスワード

## 3. 永続インフラストラクチャの作成

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws apply
```

## 4. エフェメラルインフラストラクチャのデプロイ

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral apply
```

## 5. テスト後の削除

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral destroy
```

> **注意:** 一部のリソース（例: FSx Windows ファイルシステム、Directory Service）は依存関係のため削除に時間がかかる場合があります。初回の `destroy` が失敗した場合は、数分待ってからコマンドを再実行してください。

## 作成されるリソース

| レイヤー | リソース | 説明 |
|---------|----------|------|
| 永続 | VPC | 2つの AZ にまたがるパブリック + プライベートサブネットを持つカスタム VPC |
| 永続 | インターネットゲートウェイ | パブリックサブネットのインターネットアクセス |
| エフェメラル | Managed Microsoft AD | WorkSpaces と FSx Windows 用のディレクトリ |
| エフェメラル | Amazon EFS | Elastic File System |
| エフェメラル | FSx for Windows | AD に連携した Windows ファイルサーバー |
| エフェメラル | FSx for OpenZFS | ZFS ベースのファイルシステム |
| エフェメラル | EC2 I4i | ストレージ最適化インスタンス |
| エフェメラル | EC2 Mac | Mac 専有ホスト + インスタンス |
| エフェメラル | Amazon WorkSpaces | Linux ワークスペース（Ubuntu） |
