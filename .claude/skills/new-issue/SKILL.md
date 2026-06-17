---
name: new-issue
description: CLAUDE.mdの規約に沿ったGitHub Issueを作成する（種類/優先度ラベル付与、umbrella issueの場合はSub-issuesとして紐付け）。新しいissueを作成したいときに使う。
---

# new-issue

[CLAUDE.md](../../../CLAUDE.md)の「issue/PRの分割方針」「ラベル」に沿って、
`gh issue create`でissueを作成するスキル。

## 手順

1. **種類を決める**

   - 通常issue（`feature` / `bug` / `chore` / `docs` / `ci`）
   - umbrella issue（複数のサブissueに分割される大きな変更、`umbrella`）

   既存のIssue Forms（`.github/ISSUE_TEMPLATE/`）の項目を参考に、
   以下を本文に含める。

   - **通常issue**: 背景・やること・**受け入れ条件**・技術ノート（任意）・関連
   - **umbrella issue**: 背景・全体像・サブissue一覧・関連

   `claude-ready` ラベルでissue-to-PR workflowを起動する予定のissueは、
   **受け入れ条件**（何をもって完了か）と**技術ノート**（変更対象ファイル・
   参考にすべき既存モジュール等）を具体的に書くほどAIの実装精度が上がる。

2. **ラベルを付与する**

   [.github/labels.yml](../../../.github/labels.yml)に定義されたラベルから、
   以下を最低1つずつ付与する。

   - 種類: `feature` / `bug` / `chore` / `docs` / `ci` / `umbrella`
   - 優先度: `priority: high` / `priority: medium` / `priority: low`

   ```sh
   gh issue create --title "<タイトル>" --label "<種類>" --label "<優先度>" --body "..."
   ```

3. **umbrella issueの場合: Sub-issuesとして紐付ける**

   サブissueを作成したら、GraphQLの`addSubIssue`でumbrella issueの子issue
   として登録する（他リポジトリのissueも登録可能）。

   ```sh
   PARENT_ID=$(gh api graphql -f query='query{repository(owner:"kamegoro",name:"aws-infrastructure"){issue(number:<親issue番号>){id}}}' --jq '.data.repository.issue.id')
   CHILD_ID=$(gh api graphql -f query='query{repository(owner:"kamegoro",name:"aws-infrastructure"){issue(number:<子issue番号>){id}}}' --jq '.data.repository.issue.id')
   gh api graphql -f query="mutation{addSubIssue(input:{issueId:\"$PARENT_ID\", subIssueId:\"$CHILD_ID\"}){issue{number}}}"
   ```

   - サブissueの本文には`Part of #<親issue番号>`を含める

4. **Milestoneの設定（必要な場合）**

   関連するMilestoneがあれば設定する。

   ```sh
   gh issue edit <issue番号> --milestone "<Milestone名>"
   ```
