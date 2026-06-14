# 実AWSではなくMiniStack（LocalStack互換）に接続するための設定。
# `envs/prod` 等を追加する場合は、main.tfのモジュール呼び出しをコピーし
# ここを通常の `provider "aws" {}` に置き換える。

provider "aws" {
  region = "us-east-1"

  access_key = "test"
  secret_key = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudfront             = "http://localhost:4566"                     # static-site
    cloudwatchlogs         = "http://localhost:4566"                     # fargate-service（ロググループ）
    ec2                    = "http://localhost:4566"                     # network（VPC/Subnet/SG/IGW/NAT/EIP）
    ecs                    = "http://localhost:4566"                     # fargate-service
    elasticloadbalancing   = "http://localhost:4566"                     # fargate-service（ALB）
    elasticloadbalancingv2 = "http://localhost:4566"                     # fargate-service（ALB）
    iam                    = "http://localhost:4566"                     # fargate-service（実行/タスクロール）
    rds                    = "http://localhost:4566"                     # database
    s3                     = "http://s3.localhost.localstack.cloud:4566" # static-site
    secretsmanager         = "http://localhost:4566"                     # secrets
  }
}
