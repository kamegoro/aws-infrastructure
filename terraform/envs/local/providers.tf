# This env is wired up to talk to LocalStack instead of real AWS.
# It mirrors what the `tflocal` wrapper (https://github.com/localstack/terraform-local)
# generates at runtime, but is checked in directly so plain `terraform` works
# without any extra tooling.
#
# If you later add an `envs/prod` (or similar) for real AWS, copy the modules
# wiring from main.tf but use a plain `provider "aws" {}` block there instead.

provider "aws" {
  region = "us-east-1"

  access_key = "test"
  secret_key = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    acm                    = "http://localhost:4566"
    apigateway             = "http://localhost:4566"
    cloudformation         = "http://localhost:4566"
    cloudfront             = "http://localhost:4566"
    cloudwatch             = "http://localhost:4566"
    cloudwatchlogs         = "http://localhost:4566"
    dynamodb               = "http://localhost:4566"
    ec2                    = "http://localhost:4566"
    ecr                    = "http://localhost:4566"
    ecs                    = "http://localhost:4566"
    elasticloadbalancing   = "http://localhost:4566"
    elasticloadbalancingv2 = "http://localhost:4566"
    iam                    = "http://localhost:4566"
    lambda                 = "http://localhost:4566"
    route53                = "http://localhost:4566"
    s3                     = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager         = "http://localhost:4566"
    ses                    = "http://localhost:4566"
    sns                    = "http://localhost:4566"
    sqs                    = "http://localhost:4566"
    ssm                    = "http://localhost:4566"
    sts                    = "http://localhost:4566"
  }
}
