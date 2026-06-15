---
name: diagram
description: terraform/モジュールの追加・接続関係の変更に合わせて、README.mdのMermaid構成図を更新する。terraform/modules/やterraform/envs/*/main.tfを変更したときに使う。
---

# diagram

[ADR 0003](../../../docs/adr/0003-mermaid-for-diagrams.md)・
[CLAUDE.mdのドキュメントの作法](../../../CLAUDE.md)に基づき、構成に影響する
変更があった場合にREADME.mdのMermaid図を更新するスキル。

## 更新が必要かどうかの判断

以下のいずれかに該当する変更を行った場合、README.mdの図の更新を検討する。

- `terraform/modules/`配下に新しいモジュールを追加・削除した
- `terraform/envs/*/main.tf`でモジュールの呼び出し関係・依存関係を
  変更した（新しいモジュールの呼び出し追加、モジュール間の参照変更など）
- VPC/サブネット構成やコンポーネント間の通信経路が変わった
- task-canvas / task-canvas-e2e / k8s-infrastructureなど、他リポジトリとの
  連携方法が変わった

ドキュメントのみの変更、Terraformのリソースの細部（タグ、サイズ等）の
調整など、構成図に表れない変更では更新不要。

## 更新対象

README.mdには2つのMermaid図がある。

1. **アーキテクチャ図**（`flowchart TB`）: VPC内のモジュール構成
   （`network` / `static-site` / `fargate-service` / `database` / `secrets`等）
   - モジュール追加・接続関係の変更に合わせてノード・エッジを追加/修正する
   - 図の直後にある「コンポーネント」表（モジュールと役割の対応）も
     合わせて更新する
2. **関連リポジトリ図**（`flowchart LR`）: task-canvas /
   task-canvas-e2e / k8s-infrastructureとの関係
   - 他リポジトリとの連携方法が変わった場合のみ更新する

## 手順

1. 変更内容が上記「更新が必要かどうかの判断」に該当するか確認する
2. 該当する場合、README.mdの対象のMermaidコードブロックを編集する
3. GitHub上でMermaidが正しくレンダリングされるか、PRのプレビューや
   `gh pr view --web`で確認する
