---
name: triage-ci
description: CIの失敗ログを取得し、原因がこのリポジトリのコード/設定の問題かMiniStack等外部ツールの問題かを分類する。issueを起票する場合はbugテンプレートに沿って作成する。CIが失敗したときに使う。
---

# triage-ci

[CLAUDE.mdのトラブル発生時の振る舞い](../../../CLAUDE.md)に基づき、CI失敗の
原因を切り分け、必要に応じてissueを起票するスキル。#67
（CIが失敗した場合にClaudeが調査し、対応可能ならIssueを起票するworkflow）の
ローカル版として、手動実行時にも同じ分類・テンプレートで進められるようにする。

## 手順

### 1. 失敗ログを取得する

```sh
gh run list --branch <ブランチ名> --limit 5
gh run view <run-id> --log-failed
```

### 2. 原因を分類する

CLAUDE.mdの「トラブル発生時の振る舞い」に沿って、以下のいずれかに分類する。

- **コード側の問題**（このリポジトリのTerraform/CI設定に起因）
  - 例: `terraform fmt`差分、`terraform validate`エラー、
    workflow定義のミスなど
  - → そのPR内で修正する（このスキルでのissue起票は不要）
- **ツール側（MiniStack）の問題**
  - 再現条件を確認する（特定のリソース・操作で再現するか）
  - 既知の制約（README.mdの「既知の制約」セクション）に該当しないか確認する
  - 回避策がある場合はTerraform/CIに実装し、回避策のコメントに
    上流issueへのリンクを残す
- **未調査/判断できない**
  - 追加調査が必要な場合はissueに「未調査」として記録する

### 3. issueを起票する（コード側で即座に直せない場合）

[.github/ISSUE_TEMPLATE/bug.yml](../../../.github/ISSUE_TEMPLATE/bug.yml)の
項目に沿って、`/new-issue`スキルでissueを作成する。

- 背景: CI実行へのリンク、失敗したジョブ/ステップ
- 再現手順: 失敗を再現する操作（`make tf-apply`等）
- 期待する動作 / 実際の動作
- ツール側(MiniStack等)の問題が疑われるか: 上記の分類結果を記載
- 関連: 上流issue（ministackorg/ministack等）がある場合はリンク

MiniStack側のバグの場合は、上流リポジトリへの再現手順付きissue起票も
CLAUDE.mdの方針に従って検討する。
