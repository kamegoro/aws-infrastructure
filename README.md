# aws-infrastructure

[task-canvas](https://github.com/kamegoro/task-canvas) のインフラ（Terraform）を、
本番のAWSにお金をかけずにローカルで再現・検証するためのリポジトリです。

[LocalStack](https://www.localstack.cloud/) をDockerで起動し、ローカル環境から
AWS互換APIに対して `terraform apply` できるようにしています。

## アーキテクチャ

API（ECS Fargate + ALB）とフロントエンド（S3 + CloudFront）を、同一VPC内で
管理する構成を想定しています。

```
                         Internet
                            |
              +-------------------------+
              |           VPC            |
              |                          |
  CloudFront--+--> S3 (frontend assets)  |
              |                          |
              |  ALB (public subnet)     |
              |    |                     |
              |  ECS Fargate (api)       |
              |    (private subnet)      |
              +--------------------------+
```

## 構成

```
terraform/
  modules/
    network/   VPC, サブネット, ルートテーブル, セキュリティグループ
    frontend/  S3 + CloudFront (OAC) でのフロントエンド配信
    api/       ECS Fargate + ALB でのAPI配信
  envs/
    local/     上記モジュールをまとめてLocalStack向けにワイヤリング
```

`envs/local/providers.tf` には [`tflocal`](https://github.com/localstack/terraform-local)
が生成するようなLocalStack向けのエンドポイントオーバーライドを直接記述しています。
そのため `tflocal` コマンドは不要で、通常の `terraform` コマンドのみで動作します。

将来 `envs/prod` のような実AWS向けの環境を追加する場合は、`envs/local/main.tf` の
モジュール呼び出しをコピーし、`providers.tf` を通常の `provider "aws" {}` に
置き換えてください。

## セットアップ

[mise](https://mise.jdx.dev/) でTerraformのバージョンを管理しています。

```sh
mise install
```

## 使い方

```sh
# LocalStackを起動（ヘルスチェック待ちまで行う）
make up

# terraform/envs/local を初期化してplan/apply
make tf-init
make tf-plan
make tf-apply

# 後片付け
make tf-destroy
make down
```

その他の主なターゲット:

| ターゲット | 内容 |
| --- | --- |
| `make up` / `make down` | LocalStackの起動・停止 |
| `make logs` | LocalStackのログを追跡 |
| `make tf-fmt` | `terraform fmt -recursive` |
| `make tf-validate` | `terraform/envs/local` の `terraform validate` |
| `make tf-output` | `terraform/envs/local` の出力を表示 |

## LocalStack Community版の制約について

このリポジトリはLocalStackの**Community版（無料）**を前提としています。
Community版では、`frontend`/`api` モジュールが利用する以下のサービスは
エミュレートされません（`LOCALSTACK_AUTH_TOKEN` を設定したPro版が必要）。

- CloudFront
- ECS
- ELB / ELBv2 (ALB)

一方、`network` モジュールが利用するVPC/サブネット/ルートテーブル/
セキュリティグループ（EC2系API）やS3、IAMなどはCommunity版でも利用できます。

このため、ローカルでの動作確認範囲は以下のようになります。

| モジュール | `terraform plan` | `terraform apply`（Community版） |
| --- | --- | --- |
| `network` | ✅ | ✅ 実際にVPC等が作成される |
| `frontend` | ✅ | ❌ CloudFront未対応のため失敗する |
| `api` | ✅ | ❌ ECS/ALB未対応のため失敗する |
| `envs/local`（全体） | ✅ | ❌ 上記理由でCloudFront/ECS/ALB部分が失敗する |

`network` モジュールのみを適用したい場合は `-target` を使います。

```sh
cd terraform/envs/local
terraform apply -target=module.network
terraform destroy -target=module.network
```

`frontend`/`api` を含む全体を実際に `apply` したい場合は、LocalStackの
無料アカウントで取得できる `LOCALSTACK_AUTH_TOKEN` を環境変数に設定してから
`docker compose up` してください（`docker-compose.yml` 参照）。

## CI

`.github/workflows/terraform.yml` で、`terraform/` 配下が変更された
push/pull_requestごとに以下を実行しています。

- `terraform fmt -check -recursive`
- 各モジュール・envに対する `terraform init -backend=false && terraform validate`

LocalStackへの`apply`はCIでは行わず、ローカルでの確認に留めています。
