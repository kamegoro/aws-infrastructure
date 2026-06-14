# CLAUDE.md

このリポジトリで作業する際の運用ルールです。

## 目的

[task-canvas](https://github.com/kamegoro/task-canvas) のAWSインフラ（Terraform）を、
LocalStack上でローカルに再現・検証するためのリポジトリです。本番AWSへの
コストをかけずに、Terraformの構成変更を試せることが目的です。

## 開発フロー

- 作業は `main` を起点としたfeatureブランチで行い、Pull Requestを作成する
- 意味のある単位（モジュール追加、CI追加、ドキュメント追加など）でPRを分割する
- まとまった作業をする場合は、先にGitHub Issueを作成してから着手する
- 変更はGitHub Actions（`.github/workflows/terraform.yml`）の
  `terraform fmt -check` / `terraform validate` / LocalStackでの
  `plan`・`module.network`の`apply`/`destroy`がすべてpassすることを確認する
- コミットメッセージには `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
  を付与する

## Terraformの作法

- フォーマットは必ず `terraform fmt -recursive`（`make tf-fmt`）を通す
- 新しいモジュールを追加したら `terraform/modules/<name>` に置き、
  `terraform/envs/local/main.tf` から呼び出す
- 変数・出力には `description` を付ける

## LocalStackについて

- LocalStack Community版（無料）を前提とする
- CloudFront / ECS / ELB(v2) はCommunity版では非対応
  - `network` モジュール（VPC/サブネット/SG等）はapply/destroyまで確認可能
  - `frontend` / `api` モジュールは `plan` までの確認に留める
- 詳細は [README.md](README.md) を参照
