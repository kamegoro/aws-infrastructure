# 実AWS（prod環境）に接続するための設定。
# 認証情報はAWS_PROFILE等の環境変数、もしくはCI/CDのOIDC連携で渡す想定。

provider "aws" {
  region = var.aws_region
}
