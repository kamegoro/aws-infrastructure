# CLAUDE.md

このリポジトリで作業する際の運用ルールです。

## 目的

[task-canvas](https://github.com/kamegoro/task-canvas) のAWSインフラ（Terraform）を、
MiniStack上でローカルに再現・検証するためのリポジトリです。本番AWSへの
コストをかけずに、Terraformの構成変更を試せることが目的です。

## 開発フロー

- 作業は `main` を起点としたfeatureブランチで行い、Pull Requestを作成する
- 意味のある単位（モジュール追加、CI追加、ドキュメント追加など）でPRを分割する
- まとまった作業をする場合は、先にGitHub Issueを作成してから着手する
- 変更はGitHub Actions（`.github/workflows/terraform.yml`）の
  `terraform fmt -check` / `terraform validate` / MiniStackでの
  `envs/local`全体の`plan`・`apply`/`destroy`がすべてpassすることを確認する
- コミットメッセージには `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
  を付与する

## Terraformの作法

- フォーマットは必ず `terraform fmt -recursive`（`make tf-fmt`）を通す
- 新しいモジュールを追加したら `terraform/modules/<name>` に置き、
  `terraform/envs/local/main.tf` から呼び出す
- 変数・出力には `description` を付ける

## MiniStackについて

- [MiniStack](https://github.com/ministackorg/ministack)（無料、サインアップ不要）を前提とする
- `network` / `static-site` / `fargate-service` すべてのモジュールでapply/destroyまで確認可能
- `aws_s3_bucket_public_access_block.frontend` のdestroyには既知のバグの
  回避策（`terraform state rm`）が必要
- 詳細は [README.md](README.md) を参照
