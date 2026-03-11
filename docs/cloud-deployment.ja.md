# クラウドデプロイ

Terraform を使用して AWS インフラストラクチャをデプロイします。

## デプロイ方法

- **手動（Terraform CLI）** — [AWS デプロイガイド](cloud-deployment-aws.ja.md) に従ってください
- **CI/CD（GitHub Actions）** — GitHub Actions で自動化します。[CI / GitHub Actions](ci.ja.md) を参照

## アーキテクチャ：永続 + エフェメラルレイヤー

Terraform は2つのレイヤーに分かれています：

- **永続**（`iac/aws/`）— VPC、サブネット。低コスト。常時稼働。
- **エフェメラル**（`iac/aws/ephemeral/`）— EFS、FSx、EC2、WorkSpaces など。テスト用に作成し、完了後に削除。

各エフェメラルレイヤーは `terraform_remote_state` を介して永続レイヤーの出力を読み取ります（`remote-state.tf` を参照）。

## Terraform コマンド

すべてのコマンドは Docker Compose 経由で `-chdir` を使ってレイヤーを選択して実行します。`init` コマンドにはステートバックエンドの場所を注入するために `-backend-config` が必要です：

```sh
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws apply

docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral init \
  -backend-config="bucket=YOUR_BUCKET_NAME"
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral apply
docker compose --profile=iac run --rm iac terraform -chdir=iac/aws/ephemeral destroy
```
