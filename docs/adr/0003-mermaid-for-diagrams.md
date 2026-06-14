# 0003. 構成図にはMermaidを使う

## ステータス

承認

## 背景

README.mdのアーキテクチャ図はASCIIアートで表現されていたが、`database`/
`secrets`モジュールの追加などで構成要素が増えるにつれて見づらくなっていた
（issue #62）。draw.io（diagrams.net）とMermaidを比較検討した。

## 決定

構成図・関連リポジトリ図には[Mermaid](https://mermaid.js.org/)を使い、
Markdownファイルにコードブロックとして直接記述する。

## 理由

- GitHub上のMarkdownでMermaidのコードブロックはそのままレンダリングされ、
  追加のエクスポート手順や別ファイルの管理が不要
- draw.ioは`.drawio`ソースとSVG/PNGエクスポートの両方をリポジトリに
  保持・同期する必要があり、更新時に手順を忘れると図とソースが
  ずれるリスクがある
- 図の差分がテキストのdiffとしてレビューできる

## 影響

- README.mdのアーキテクチャ図・関連リポジトリ図はMermaidで記述する
- 構成変更時は、対応するMermaid図をPR内で更新する
  （CLAUDE.mdの「ドキュメントの作法」に記載）
- 複雑なフリーハンドの図解が必要になった場合は、改めてdraw.io等の
  採用を検討する
