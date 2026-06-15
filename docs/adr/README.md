# ADR (Architecture Decision Records)

このディレクトリには、このリポジトリにおける主要な設計・運用上の意思決定を記録します。

## フォーマット

各ADRは `NNNN-短い説明.md` という形式のファイル名で、以下のセクションを含めます。

- **ステータス**: `提案 / 承認 / 廃止` のいずれか
- **背景**: 何が課題だったか
- **決定**: 何を選んだか
- **理由**: なぜそれを選んだか（代替案との比較を含む）
- **影響**: この決定によって何が変わるか

## 一覧

| ADR | タイトル |
| --- | --- |
| [0001](0001-migrate-from-localstack-to-ministack.md) | LocalStackからMiniStackへの移行 |
| [0002](0002-inline-security-group-ingress.md) | セキュリティグループのingressをインラインで定義する |
| [0003](0003-mermaid-for-diagrams.md) | 構成図にはMermaidを使う |
| [0004](0004-claude-code-action-guardrails.md) | claude-code-actionのガードレール方針 |
| [0005](0005-tfsec-exclusions.md) | tfsecの導入と検出項目の除外方針 |
| [0006](0006-branch-protection-main.md) | mainブランチへのBranch Protection設定 |
