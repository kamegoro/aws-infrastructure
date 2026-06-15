---
name: tf-check
description: Terraformの変更をコミット/PR前にチェックする（fmt → validate → 必要に応じてMiniStackでのplan/apply/destroy）。terraform/配下を編集した後に使う。
---

# tf-check

`terraform/`配下を変更した際に、CI（`.github/workflows/terraform.yml`）で
落ちる前にローカルで検証するためのスキル。

## 手順

1. **フォーマット**

   ```sh
   make tf-fmt
   ```

   （`terraform fmt -recursive`を実行する。差分が出た場合はそのまま
   コミット対象に含める）

2. **validate**

   `terraform/envs/`配下の各ディレクトリ（`local` / `dev` / `stg` / `prod`）
   のうち、変更が影響する環境について実行する。基本的には全環境を
   チェックする。

   ```sh
   for dir in terraform/envs/*/; do
     (cd "$dir" && terraform init -backend=false -input=false >/dev/null && terraform validate)
   done
   ```

   - `local`のみ`make tf-validate`でも可（`TF_DIR=terraform/envs/local`）

3. **MiniStackでのplan/apply/destroy（Terraformのリソース定義を変更した場合）**

   `envs/local`に対して、実際にMiniStack上でapply/destroyまで確認する。

   ```sh
   make up
   make tf-init
   make tf-plan
   make tf-apply
   # 動作確認
   make tf-destroy
   ```

   - 既知の制約（`aws_s3_bucket_public_access_block.frontend`のdestroy等）は
     [README.md](../../../README.md#既知の制約-s3-public-access-blockのdestroy)を参照
   - ドキュメントのみの変更やCI設定の微調整など、Terraformのリソース定義に
     影響しない変更ではこのステップは不要

4. **CI確認**

   PR作成後、`gh pr checks <PR番号> --watch`で全チェックがpassすることを
   確認する。
