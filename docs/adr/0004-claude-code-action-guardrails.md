# 0004. claude-code-actionのガードレール方針

## ステータス

承認

## 背景

#63（自律的な開発サイクルの土台づくり）では、
[anthropics/claude-code-action](https://github.com/anthropics/claude-code-action)
を基盤として、Dependabot PRの自動レビュー（#66）、CI失敗時のIssue起票（#67）、
issue-to-PR（#68）、セカンドレビュー（#70）などのworkflowを段階的に追加していく。

これらのworkflowに何の制約もなく`contents: write`や`gh pr merge`相当の権限を
与えると、誤った判断によるマージ・push・destroy系操作が連鎖的に発生する
「暴走」のリスクがある。各workflowを個別に追加する前に、共通の権限方針と
無効化手段を決めておく必要がある。

## 決定

1. **権限の最小化**: claude-code-actionを使うworkflowには、原則として
   `contents: write`を付与しない。`contents: read` / `issues: write` /
   `pull-requests: write`の範囲に留める。
   - **例外1**: `.github/workflows/dependabot-auto-merge.yml`（#66）は
     `contents: write`（マージ権限）を持つが、claude-code-actionは
     使用しない。ラベル（`auto-merge-approved`の有無、
     `needs-human-review`が無いこと）・PR作成者が`dependabot[bot]`
     であること・CIの全チェック結果という、LLMの出力を介さない
     機械的な条件のみでマージ可否を判定する。これにより、決定事項2の
     「ラベル方式の間接的な自動化」を保ったまま、最終的なマージ
     アクション自体は人間が読める条件分岐に委ねている。
   - **例外2**: `.github/workflows/claude-issue-to-pr.yml`（#68）は
     issueの実装・ブランチpush・PR作成のために`contents: write`を
     claude-code-actionに直接付与する。以下で影響範囲を限定する。
     - `claude-ready`ラベル付与（write権限が必要）のみで起動する
     - `--disallowedTools`で`terraform apply`/`destroy`、
       `gh pr merge`/`close`、`gh secret`、`main`への直接push・
       force pushを禁止する
     - プロンプトで「`main`に直接コミットしない」
       「作成したPRは自分でマージ・承認しない」ことを明示する
     - 作成されたPRには`needs-human-review`を付与し、
       人間のレビューを必須とする（決定事項2に従い、マージは
       人間または別workflowが行う）
     - `terraform apply`/`destroy`やMiniStackでのE2E確認はこの
       workflow内では行わず、PRに対する既存CI（`terraform.yml`）の
       結果をレビュー担当者が確認する
2. **ラベル方式の間接的な自動化**: マージ・適用などの最終アクションが
   必要な場合、Claudeは判定結果を`auto-merge-approved`等のラベル付与や
   コメントに留める。実際のマージ・apply等は、人間が読める権限設定を持つ
   別workflow（またはユーザー自身）がラベルを見て実行する。
3. **無効化スイッチ（kill switch）**: claude-code-actionを使う各workflowは、
   リポジトリ変数`CLAUDE_AUTOMATION_ENABLED`（デフォルト`true`）を先頭で
   チェックし、`false`の場合は何もせず終了する。暴走時はこの変数を
   `false`にするだけで全自動化を停止できる。
4. **同時実行制御**: 各workflowに`concurrency`グループを設定し、
   同一PR/issueに対する重複実行やAPIレート制限超過を防ぐ。
   グループ名は`<workflow名>-<issue/PR番号>`
   （例: `claude-${{ github.event.issue.number || github.event.pull_request.number }}`）
   とし、`cancel-in-progress: false`で実行中のジョブは完了まで待つ
   （後続のイベントは同じグループ内でキューイングされる）。
5. **draft PRの除外**: PRレビュー関連のイベント
   （`pull_request_review` / `pull_request_review_comment`）では、
   対象PRが draft の場合はジョブをスキップする。WIP中のPRに対する
   不要な実行を防ぎ、APIコストを抑える。
6. **API使用量の監視**: [Anthropic Console](https://console.anthropic.com/)の
   Usageダッシュボードで、claude-code-actionによるAPI使用量・コストを
   定期的に確認する。予算超過の懸念がある場合は
   `CLAUDE_AUTOMATION_ENABLED`をリポジトリ変数で`false`に設定して停止する。
7. **CLAUDE_CODE_OAUTH_TOKENの運用方針**: `ANTHROPIC_API_KEY`の代わりに、
   kamegoroのClaude.ai Pro/Maxサブスクリプションに紐づく
   `claude setup-token`発行のOAuthトークンを`CLAUDE_CODE_OAUTH_TOKEN`として
   使用する（#125）。このトークンは個人の利用枠を自動化workflowと共有するため、
   以下の運用ルールを設ける。
   - **レート制限/使用量の共有**: このトークンの使用量は、kamegoroが
     対話的に`claude`を使う際の利用枠と共有される。自動化workflowの
     実行が増えると、対話的な利用に影響する可能性がある。
   - **使用量の確認方法**: `claude`コマンドの使用量表示、または
     [claude.aiの使用量ページ](https://claude.ai/settings/usage)で
     定期的に消費量を確認する。
   - **kill switchの再確認**: 想定外にトークンが消費されている場合は、
     決定事項3の`CLAUDE_AUTOMATION_ENABLED=false`により、即座に
     全automation workflowを停止できる。
   - **`claude-ready`ラベルによる発火対象の限定**（#126）: `claude.yml`
     （`@claude`メンション応答）は、issue/PRに`claude-ready`ラベルが
     付与されている場合のみ発火する。これにより、kamegoroが意図した
     issue/PRのみでOAuthトークンが消費される。
   - **`--max-turns`によるターン数上限**（#126）: claude-code-actionを
     使う各workflowには`claude_args`で`--max-turns`を設定し、1回の
     実行が消費するトークン量に上限を設ける。
   - **`allowed_non_write_users` / `allowed_bots`は設定しない**:
     claude-code-actionのデフォルト動作（write権限を持たない
     actorからのトリガーは`prepare`ステップで拒否される）を
     アクセス制御の基本とする。これらの入力を設定して
     デフォルトの拒否を緩めることはしない。
   - **fork PRでの`security-review.yml`**: `pull_request`イベントの
     fork PRには`secrets`が渡されないため、`security-review.yml`は
     fork PRに対して自動的にno-opとなる（`ANTHROPIC_API_KEY`が
     空になりkill switchと同じ判定になる）。追加の対策は不要。
   - **トークンの更新手順**: `CLAUDE_CODE_OAUTH_TOKEN`は長期間有効だが、
     失効・無効化された場合は、kamegoroのローカル環境で
     `claude setup-token`を再実行し、出力されたトークンで
     リポジトリのSecrets（`CLAUDE_CODE_OAUTH_TOKEN`）を再登録する。
     更新中は各workflowのkill switchが「未登録」と同じ扱いで
     no-opになるため、CIが失敗することはない。

## 理由

- ラベル方式は、Claudeの判断ミスがあっても実際の変更（マージ等）が
  発生しないため、被害を1段階で止められる
  ([CyberAgent](https://developers.cyberagent.co.jp/blog/archives/60598/)、
  [Zenn記事](https://zenn.dev/genda_jp/articles/b3ba6a578714ca))
- リポジトリ変数1つで全体を止められるkill switchは、実装コストが低く、
  緊急時に最も早く効く対策である
- `concurrency`制御は2026年時点のベストプラクティスとしても挙げられており、
  レート制限・コスト超過の防止に有効
  ([Claude Code GitHub Actions Docs](https://code.claude.com/docs/en/github-actions))
- Dependabot PRのレビュー（#66）は、PR本文やdiffに埋め込まれた
  プロンプトインジェクションでClaudeが`auto-merge-approved`を誤って
  付与するリスクがある。メジャーバージョンアップを常に
  `needs-human-review`に分類するルールと、Claudeのツールを
  `gh pr view`/`gh pr diff`の読み取りのみに限定することで、
  影響範囲を「誤ったラベル付与」までに抑える。最終的なマージ判定
  （`dependabot-auto-merge.yml`）はLLMを介さずラベル・CI結果のみで
  行うため、プロンプトインジェクションが直接マージには繋がらない

## 影響

- #65以降、claude-code-actionを使う各workflowの`permissions`は
  `contents: read`を基本とし、`contents: write`が必要な場合は
  個別にこのADRを更新して理由を記載する
- 各workflowの先頭に`CLAUDE_AUTOMATION_ENABLED`のチェック処理を入れる
- ラベル体系（`.github/labels.yml`）の`auto-merge-approved` /
  `needs-human-review`等を、この方針に基づいて運用する
- 各workflowに`concurrency`グループとdraft PR除外条件
  （PRレビュー関連イベントのみ）を設定する
- API使用量の監視は人間がAnthropic Consoleで行う運用とし、
  workflow側に追加の仕組みは設けない
- `CLAUDE_CODE_OAUTH_TOKEN`の使用量はclaude.aiの使用量ページ等で
  kamegoroが定期的に確認する運用とし、消費が想定外に増えた場合は
  `CLAUDE_AUTOMATION_ENABLED=false`で全automation workflowを停止する
- `claude.yml`は`claude-ready`ラベルが付与されたissue/PRでのみ
  `@claude`メンションに応答する（#126）
- `dependabot-review.yml`はDependabot作成のPR（`pull_request.user.login
  == 'dependabot[bot]'`）のみを対象とし、判定結果を`auto-merge-approved`/
  `needs-human-review`ラベルとコメントに留める（決定事項1の例外なし）
- `dependabot-auto-merge.yml`は決定事項1の例外として`contents: write`を
  持つが、claude-code-actionは使用せず、PR作成者・ラベル・CI結果のみで
  マージ可否を判定する（#66）
- `claude-issue-to-pr.yml`は決定事項1の例外として`contents: write`を
  claude-code-actionに付与するが、`claude-ready`ラベルでの起動・
  `--disallowedTools`による危険操作の禁止・作成PRへの
  `needs-human-review`付与・人間によるレビュー必須、により
  影響範囲を限定する（#68）
- `claude-pr-second-review.yml`は`claude/issue-*`ブランチ（同一リポジトリ
  内のみ）への`needs-human-review`付与を契機に起動し、`contents: read`の
  範囲でレビューコメント・`reviewed-by-claude`ラベル付与のみを行う（#70）
