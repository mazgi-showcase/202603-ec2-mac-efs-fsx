# OIDC セットアップ

GitHub の OIDC トークン発行者と AWS アカウント間の信頼関係を作成するための一度限りのセットアップです。

## AWS: IAM OIDC プロバイダー + IAM ロール

1. **OIDC ID プロバイダーの作成:**

   ```sh
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
   ```

   > **注意:** 2023年7月以降、AWS は GitHub を信頼されたルート CA に追加したため、サムプリントの値は検証されなくなりました。`--thumbprint-list` パラメータは CLI で引き続き必須ですが、値は実質的に無視されます。

2. **信頼ポリシーを持つ IAM ロールの作成:**

   `trust-policy.json` を作成します（`ACCOUNT_ID` と `OWNER/REPO` を置き換えてください）：

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
           },
           "StringLike": {
             "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:*"
           }
         }
       }
     ]
   }
   ```

   ```sh
   aws iam create-role \
     --role-name github-actions-iac \
     --assume-role-policy-document file://trust-policy.json
   ```

3. **権限の付与。** ロールには以下へのアクセスが必要です: S3（ステートバックエンド）、VPC、EC2、EFS、FSx、Directory Service、WorkSpaces、IAM。

4. **変数の設定:** GitHub Actions の変数に `AWS_IAM_ROLE_ARN` を追加します。

**ヒント:** より厳密な制御を行うには、`sub` 条件を特定のブランチに制限できます。例: `repo:OWNER/REPO:ref:refs/heads/main`
