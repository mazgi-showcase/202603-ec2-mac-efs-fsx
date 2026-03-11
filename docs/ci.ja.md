# CI / GitHub Actions

## ワークフロー

### IaC（Terraform）

| ワークフロー | 説明 |
|-------------|------|
| `iac.yaml` | 永続レイヤー: PR = plan、main への push = apply。 |
| `iac.ephemeral.yaml` | エフェメラルレイヤー: 手動ディスパッチ（plan/apply/destroy）。 |

## 環境ファイルの命名規則

| ファイル | 用途 |
|---------|------|
| `.example.env` / `.example.secrets.env` | テンプレート（リポジトリにコミット済み） |
| `.env` / `.secrets.env` | ローカル開発用 |

## セットアップ

1. **変数** — `cp .example.env .env` で作成・編集し、アップロード:

   ```sh
   gh variable set --env-file .env
   ```

2. **シークレット** — `cp .example.secrets.env .secrets.env` で作成・編集し、アップロード:

   ```sh
   gh secret set --env-file .secrets.env
   ```

3. **OIDC 認証** — [OIDC セットアップ](oidc-setup.ja.md) を参照

### 変数・シークレットのリセット

```sh
gh variable list --json name --jq '.[].name' | xargs -I {} gh variable delete {}
gh secret list --json name --jq '.[].name' | xargs -I {} gh secret delete {}
```

## 必須変数

### Terraform ステートバックエンド

| 変数 | 例 |
|------|-----|
| `AWS_TF_STATE_BUCKET` | `my-tf-state-bucket` |
| `AWS_TF_STATE_REGION` | `us-east-1` |

### AWS 識別子

| 変数 | 例 |
|------|-----|
| `AWS_IAM_ROLE_ARN` | `arn:aws:iam::123456789012:role/github-actions-iac` |
| `TF_VAR_app_unique_id` | `my-infra` |
| `TF_VAR_aws_region` | `us-east-1` |
| `TF_VAR_ec2_mac_availability_zone_id` | `use1-az4` |
| `TF_VAR_workspace_bundle_id` | `wsb-xnp4cfzht` |

## 必須シークレット

| シークレット | 説明 |
|-------------|------|
| `TF_VAR_ad_admin_password` | Managed Microsoft AD 管理者パスワード |
