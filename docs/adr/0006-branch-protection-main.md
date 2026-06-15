# 0006. mainブランチへのBranch Protection設定

## ステータス

承認

## 背景

#68（`claude-issue-to-pr.yml`）でclaude-code-actionに初めて`contents: write`
（push権限）を付与した。`--disallowedTools`やプロンプトでの指示で`main`への
直接push・force pushを禁止しているが、これはLLMの判断に依存した
「お願い」レベルの制御であり、GitHubのリポジトリ設定による強制力はない。

また、`dependabot-auto-merge.yml`（#66）も`contents: write`でPRをマージする
ため、マージ操作自体が正しくPR経由であることを保証する設定が望ましい。

## 決定

`main`ブランチに以下のBranch Protectionを設定する。

- **Require a pull request before merging**を有効化する
  （`required_pull_request_reviews.required_approving_review_count: 0`）
  - 承認は必須としない（kamegoroが自分のPRを都度自己承認する運用は
    煩雑なため）。目的は「直接pushの禁止」であり、レビュー強制では無い
- **Include administrators**を有効化する（`enforce_admins: true`）
  - kamegoro自身もmainへの直接push・force pushができなくなる
  - 既存の開発フロー（feature branch → PR →
    `gh pr merge --squash --delete-branch`）と一致するため、
    通常運用への影響はない
- **Allow force pushes** / **Allow deletions**は無効化する
- **必須ステータスチェック（required status checks）は設定しない**
  - `terraform.yml`の各チェックは`terraform/**`を変更するPRのみで
    実行されるため、ドキュメントのみのPR等では該当チェックが
    一度も実行されず、必須チェックに指定すると永久にpendingで
    マージ不可になってしまう
  - CIが全てpassすることの確認は、引き続きCLAUDE.mdの規約
    （`gh pr checks`で確認してからマージ）という運用ルールで担保する

## 理由

- `claude-issue-to-pr.yml`・`dependabot-auto-merge.yml`に付与した
  `contents: write`の影響範囲を、「PR経由のマージのみ」に
  リポジトリ設定として強制できる
- `required_approving_review_count: 0`により、ソロメンテナ運用での
  マージのしやすさは維持しつつ、直接pushのみを禁止できる
- 必須ステータスチェックを設定しないことで、パスフィルタにより
  一部PRでスキップされるチェックが原因でマージ不可になる事故を防ぐ

## 影響

- `dependabot-auto-merge.yml`の`gh pr merge --squash`は、PR経由の
  マージとして引き続き正常に動作する（マージ操作自体は
  push制限の対象外）
- kamegoroが緊急時にローカルから`git push origin main`することは
  できなくなる。常にfeatureブランチ + PRが必要になる
- 今後、`terraform.yml`の各チェックを必須ステータスチェックとして
  指定したい場合は、パスフィルタで実行されないPRでもマージ可能にする
  workaround（例: パスに関わらず常に1つは実行されるチェックを必須化する）
  を別途検討し、本ADRを更新する
