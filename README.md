# aws-infrastructure

[task-canvas](https://github.com/kamegoro/task-canvas) のインフラ（Terraform）を、
本番のAWSにお金をかけずにローカルで再現・検証するためのリポジトリです。

[MiniStack](https://github.com/ministackorg/ministack) をDockerで起動し、ローカル環境から
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
    local/     上記モジュールをまとめてMiniStack向けにワイヤリング
```

`envs/local/providers.tf` には [`tflocal`](https://github.com/localstack/terraform-local)
が生成するようなLocalStack互換のエンドポイントオーバーライドを直接記述しています。
MiniStackはLocalStackと同じエンドポイント形式をエミュレートするため、
`tflocal` コマンドは不要で、通常の `terraform` コマンドのみで動作します。

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
# MiniStackを起動（ヘルスチェック待ちまで行う）
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
| `make up` / `make down` | MiniStackの起動・停止 |
| `make logs` | MiniStackのログを追跡 |
| `make tf-fmt` | `terraform fmt -recursive` |
| `make tf-validate` | `terraform/envs/local` の `terraform validate` |
| `make tf-output` | `terraform/envs/local` の出力を表示 |

## MiniStackについて

[MiniStack](https://github.com/ministackorg/ministack) はLocalStack互換の
AWSエミュレータで、MITライセンスでサインアップ不要、`network`/`frontend`/`api`
すべてのモジュールが利用するサービス（VPC/SG、S3、CloudFront、ECS、ELBv2）を
無料でエミュレートします。ECSタスクはホストのDocker socketを使って実際の
コンテナとして起動されます。

| モジュール | `terraform plan` | `terraform apply` |
| --- | --- | --- |
| `network` | ✅ | ✅ |
| `frontend` | ✅ | ✅ |
| `api` | ✅ | ✅ |
| `envs/local`（全体） | ✅ | ✅ |

```sh
cd terraform/envs/local
terraform apply
terraform destroy
```

### 既知の制約: S3 Public Access Blockのdestroy

MiniStack 1.3.63には、`DeletePublicAccessBlock` が成功を返すものの
`GetPublicAccessBlock` が以前の設定を返し続けるバグがあり、
`aws_s3_bucket_public_access_block.frontend` の `terraform destroy` が
タイムアウトします（[ministackorg/ministack#915](https://github.com/ministackorg/ministack/issues/915)）。

destroyする際は、事前にこのリソースをstateから外してください。

```sh
cd terraform/envs/local
terraform state rm module.frontend.aws_s3_bucket_public_access_block.frontend
terraform destroy
```
