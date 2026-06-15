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

## issue/PRの分割方針

- 複数のステップに分かれる大きな変更は、まず「umbrella issue（親issue）」を作成し、
  背景・全体像・サブissueへのチェックリストを書く
  - 例: #20（LocalStack→MiniStack移行）→ #21〜#24
  - 例: #43（モジュールのリネーム）→ #44, #45
- サブissueを作成したら、GitHubのSub-issues機能（`gh api graphql`の
  `addSubIssue`、またはWeb UI）でumbrella issueの子issueとして登録する
  - 進捗はSub-issuesの進捗バーで確認できるため、本文中に重複した
    チェックリストを残す場合は最小限の説明に留める
  - 他リポジトリ（例: task-canvas-e2e）のissueも子issueとして登録できる
- サブissueはumbrella issueへのリンク（`Part of #N`）を本文に含める
- サブissueごとに1つのfeatureブランチ・1つのPRを作成し、PR本文に`Closes #N`を書く
  （マージ時にサブissueが自動でクローズされる）
- すべてのサブissueが完了したら、umbrella issueに完了サマリをコメントして
  手動でクローズする
- 単発の小さな変更（バグ修正、CI設定の微調整など）は、umbrella issueを作らず
  通常issue1件→PR1件で進めてよい
- 着手前にissueの内容を調査した結果、複数のサブタスクに分割すべきと
  判明した場合は、実装に着手する前に以下を行う
  - 元issueのタイトルに`[umbrella]`を付け、調査結果に基づいた
    サブissueへのチェックリストを書く
  - サブissueを作成し、それぞれの本文に`Part of #N`を含める
  - 例: #30（実バックエンドイメージへの切替）→ #72, #73
  - その後はサブissueごとに通常のフロー（ブランチ→PR→`Closes #N`）で進める

## ラベル

ラベルの定義は[.github/labels.yml](.github/labels.yml)で管理する。
新規issueには以下を付与する。

- 種類: `feature` / `bug` / `chore` / `docs` / `ci` / `umbrella` のいずれか1つ
- 優先度: `priority: high` / `priority: medium` / `priority: low` のいずれか1つ

以下は自動化workflow（#63）が使用する状態ラベルで、人間が手動で付与する
必要は基本的にない。

- `auto-merge-approved` / `needs-human-review` / `reviewed-by-claude` / `claude-ready`

## claude-code-actionのガードレール

`.github/workflows/claude.yml`等、claude-code-actionを使うworkflowは
[ADR 0004](docs/adr/0004-claude-code-action-guardrails.md)の方針に従う。

- `contents: write`は原則付与しない（マージ・push等は人間またはラベル経由の
  別workflowが行う）
- 各workflowはリポジトリ変数`CLAUDE_AUTOMATION_ENABLED`を先頭でチェックし、
  `false`の場合は何もしない（暴走時の一括停止スイッチ）
- 同一PR/issueへの重複実行を防ぐため`concurrency`グループを設定する

## トラブル発生時の振る舞い

- MiniStack/Terraformでエラーが発生した場合、まず原因がコード側（このリポジトリの
  Terraform/CI設定）かツール側（MiniStack本体）かを切り分ける
- コード側の問題はそのPR内で修正する
- ツール側（MiniStack）のバグの場合:
  - 再現条件を確認し、回避策をTerraform/CIに実装する
    （例: [既知の制約: S3 Public Access Blockのdestroy](README.md#既知の制約-s3-public-access-blockのdestroy)）
  - 回避策と合わせて、上流（[ministackorg/ministack](https://github.com/ministackorg/ministack)）に
    再現手順付きのissueを立てる（例: ministackorg/ministack#915, #916）
  - 回避策のコード上のコメントに、上流issueへのリンクを残す
- 意思決定の背景は `docs/adr/` にADR（Architecture Decision Record）として記録する

## コミット・PRの規約

- コミットメッセージ
  - 1行目: `<type>: <変更内容の要約>`（`feat` / `fix` / `refactor` / `docs` / `ci` / `chore` など）
  - 本文: 変更の背景・内容を日本語で記述する
  - 末尾に `Closes #N`（PRがissueをクローズする場合）または `Part of #N`
    （umbrella issueの一部の場合）を書く
  - さらに末尾に `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` を付与する
- PR本文
  - `## 概要` / `## 変更内容` / `## 確認` のセクションで構成する
  - issueをクローズする場合は `Closes #N` を含める
  - `gh pr checks` で全チェックがpassすることを確認してからマージする
  - マージは `gh pr merge --squash --delete-branch` を使用する

## ドキュメントの作法

- README.mdの構成図・関連リポジトリ図は[Mermaid](https://mermaid.js.org/)で
  Markdownに直接記述する（[ADR 0003](docs/adr/0003-mermaid-for-diagrams.md)）
- モジュールの追加・接続関係の変更など、構成に影響する変更を行ったPRでは、
  README.mdの該当するMermaid図も合わせて更新する

## Terraformの作法

- フォーマットは必ず `terraform fmt -recursive`（`make tf-fmt`）を通す
- 新しいモジュールを追加したら `terraform/modules/<name>` に置き、
  `terraform/envs/local/main.tf` から呼び出す
- 変数・出力には `description` を付ける
- 新しいモジュールが新たなAWSサービスを利用する場合は、
  `terraform/envs/local/providers.tf` の `endpoints` ブロックに
  該当サービスのエンドポイントを追加し、どのモジュールが使用するかを
  コメントで明記する（不要になったエンドポイントは削除する）
- MiniStackでは実ACMのDNS検証ができないため、実AWS（dev/stg/prod）でのみ
  使う機能（例: `fargate-service`の`enable_https`/`acm_certificate_arn`）は
  デフォルトで無効化し、`envs/local`からは設定しない

## MiniStackについて

- [MiniStack](https://github.com/ministackorg/ministack)（無料、サインアップ不要）を前提とする
- `network` / `static-site` / `fargate-service` / `database` / `secrets` すべてのモジュールでapply/destroyまで確認可能
- `aws_s3_bucket_public_access_block.frontend` のdestroyには既知のバグの
  回避策（`terraform state rm`）が必要
- 詳細は [README.md](README.md) を参照
