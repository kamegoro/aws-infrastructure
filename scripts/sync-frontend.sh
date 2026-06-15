#!/usr/bin/env bash
# MiniStack上のS3バケット(static-siteモジュール)に、ローカルの静的アセット
# ディレクトリをアップロードする。バケット名はterraform/envs/localの
# outputから取得するため、事前に`terraform apply`済みであること。
#
# Usage: scripts/sync-frontend.sh <静的アセットディレクトリ>
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <静的アセットディレクトリ>" >&2
  exit 1
fi

FRONTEND_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/../terraform/envs/local"

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "Error: ${FRONTEND_DIR} はディレクトリではありません" >&2
  exit 1
fi

BUCKET_NAME="$(terraform -chdir="$TF_DIR" output -raw frontend_bucket_name)"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

# MiniStackはAWS CLIのデフォルトのチェックサムアルゴリズム(CRC64NVME)を
# サポートしていないため、SHA256等を使うように指定する
export AWS_REQUEST_CHECKSUM_CALCULATION="${AWS_REQUEST_CHECKSUM_CALCULATION:-WHEN_REQUIRED}"

aws --endpoint-url=http://s3.localhost.localstack.cloud:4566 \
  s3 sync "$FRONTEND_DIR" "s3://${BUCKET_NAME}" --delete
