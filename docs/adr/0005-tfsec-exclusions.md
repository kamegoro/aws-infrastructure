# 0005. tfsecの導入と検出項目の除外方針

## ステータス

承認

## 背景

#52（CIに静的解析を追加する）の調査として`tfsec terraform/`を実行した結果、
129件（critical: 27, high: 46, medium: 26, low: 30）、26種類のルールが検出された。

このリポジトリは[task-canvas](https://github.com/kamegoro/task-canvas)のAWS構成を
MiniStack上でローカルに再現・検証することが目的であり、本番グレードの
ハードニング（WAF、KMS CMK、VPC Flow Logs、アクセスログ、Performance Insights等）を
すべて満たすことは目的に合わない。一方、無料かつMiniStackでも動作確認できる
改善はコストなく適用できる。

## 決定

検出された26ルールを以下の2種類に分類した。

### 対応したもの（コードで修正）

| ルール | 内容 | 対応 |
| --- | --- | --- |
| AVD-AWS-0124 | SGルールに`description`がない | 全egressルールに`description`を追加 |
| AVD-AWS-0030 | ECRリポジトリのイメージスキャンが無効 | `image_scanning_configuration.scan_on_push = true` |
| AVD-AWS-0031 | ECRリポジトリのタグが可変(`MUTABLE`) | `image_tag_mutability = "IMMUTABLE"` |
| AVD-AWS-0088 | S3バケットのデフォルト暗号化が無効 | `aws_s3_bucket_server_side_encryption_configuration`（SSE-S3）を追加 |
| AVD-AWS-0090 | S3バケットのバージョニングが無効 | `aws_s3_bucket_versioning`を追加 |
| AVD-AWS-0080 | RDSのストレージ暗号化が無効 | `storage_encrypted = true` |
| AVD-AWS-0077 | RDSのバックアップ保持期間が短い | `backup_retention_period = 7` |
| AVD-AWS-0052 | ALBが無効なヘッダーをドロップしない | `drop_invalid_header_fields = true` |

### 除外するもの（`.tfsec/config.yml`で除外）

| ルール | 内容 | 除外理由 |
| --- | --- | --- |
| AVD-AWS-0107 | SGのingressが`0.0.0.0/0`に開いている | ALBを公開エンドポイントとする構成上の前提（[ADR 0002](0002-inline-security-group-ingress.md)） |
| AVD-AWS-0104 | SGのegressが`0.0.0.0/0`に開いている | 上記と同様、アーキテクチャ上必要 |
| AVD-AWS-0053 | ALBが公開（`internal = false`）になっている | 上記と同様、ALBを公開する構成が前提 |
| AVD-AWS-0164 | パブリックサブネットでパブリックIPを自動付与している | パブリックサブネットにALB等を配置する構成上必要 |
| AVD-AWS-0054 / AVD-AWS-0013 | ALB/CloudFrontでHTTPS（カスタム証明書・最新TLSポリシー）が必須化されていない | #51で実AWS向けには`enable_https`/ACM対応済み。MiniStackは実ACMのDNS検証ができないため`envs/local`では無効化している（[Terraformの作法](../../CLAUDE.md#terraformの作法)） |
| AVD-AWS-0011 | CloudFrontにWAFが設定されていない | WAFは追加コストがかかり、ローカル学習用途では不要 |
| AVD-AWS-0178 | VPCのFlow Logsが無効 | 追加のログストレージ・コストを要し、ローカル学習用途での検証価値が低い |
| AVD-AWS-0089 / AVD-AWS-0010 | S3/CloudFrontのアクセスログが無効 | 上記と同様、追加のログストレージ・コストを要する |
| AVD-AWS-0017 / AVD-AWS-0033 / AVD-AWS-0098 / AVD-AWS-0132 | CloudWatch Logs/ECR/Secrets Manager/S3がKMS CMKで暗号化されていない（デフォルトのAWS管理キーを使用） | KMS CMKは追加コストがかかり、MiniStackでのKMS機能も限定的なため対象外 |
| AVD-AWS-0177 | RDSの削除保護が無効 | `skip_final_snapshot = true`と合わせて、MiniStackでの`destroy`を妨げないようにするため意図的に無効化している |
| AVD-AWS-0176 | RDSのIAM認証が無効 | IAM認証はMiniStackでの動作確認が難しく、構成も複雑になるため対象外 |
| AVD-AWS-0133 | RDSのPerformance Insightsが無効 | 追加コストがかかり、ローカル学習用途では不要 |
| AVD-AWS-0034 | ECSクラスタのContainer Insightsが無効 | 追加コストがかかり、ローカル学習用途では不要 |

## 理由

- 無料かつMiniStackで動作確認できる改善は積極的に取り込み、セキュリティ
  ベースラインを上げる
- 一方、追加のAWSリソース・コストが発生する項目や、このリポジトリの目的
  （ローカル学習・検証）に対して検証価値が低い項目は、除外理由を本ADRに
  明記したうえで`.tfsec/config.yml`で除外する
- 除外は「やらない」ではなく「現時点ではスコープ外」であることを明示し、
  将来実AWS環境での運用を強化する際の参照先とする

## 影響

- `.github/workflows/terraform.yml`に`tfsec`ジョブを追加し、上記の除外設定
  （`.tfsec/config.yml`）を適用した状態でCIがpassすることを継続的に確認する
- 新たにtfsecが検出する項目が増えた場合、上記の表に基づき
  「対応する」か「除外してこのADRに追記する」かを判断する
