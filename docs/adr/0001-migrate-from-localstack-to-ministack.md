# 0001. LocalStackからMiniStackへの移行

## ステータス

承認

## 背景

このリポジトリは、当初[LocalStack](https://github.com/localstack/localstack)
（`localstack/localstack:4.14.0`）をAWSエミュレータとして使用していた。

2026年3月、LocalStackはCommunity版を廃止し、無料利用にもアカウント登録と
auth tokenが必要になった。pin済みのイメージ自体は動作するものの、
CloudFront/ECS/ELBv2はそもそもCommunity版では非対応であり、
`envs/local` の `frontend`（現`static-site`）/`api`（現`fargate-service`）
モジュールはローカルで `apply` まで確認できていなかった（#20）。

## 決定

AWSエミュレータを[MiniStack](https://github.com/ministackorg/ministack)に
移行する。

## 理由

- MITライセンスでアカウント登録・auth tokenが不要
- ECS（実Dockerコンテナとして起動）/ ELBv2(ALB) / CloudFront / EC2(VPC) を
  含め56以上のサービスに対応しており、このリポジトリの全モジュールを
  `apply`/`destroy`まで確認できる
- Terraformの`endpoints`ブロックがLocalStackと概ね同じ形式で使えるため、
  `tflocal`のような追加コマンドなしに通常の`terraform`コマンドのみで動作する

## 影響

- `docker-compose.yml` / `Makefile` をMiniStack向けに更新（#21）
- `envs/local`全体（network + frontend + api）をMiniStackでapply/destroy確認（#22）
- CI（`.github/workflows/terraform.yml`）をMiniStackでのフルapply/destroyに移行（#23）
- README / CLAUDE.mdをMiniStackでの動作内容に更新（#24）
- MiniStack側のバグ（S3 Public Access Blockのdestroyタイムアウト等）に
  ついては、回避策をCIに実装しつつ上流に報告する運用とした
  （[ministackorg/ministack#915](https://github.com/ministackorg/ministack/issues/915)）
