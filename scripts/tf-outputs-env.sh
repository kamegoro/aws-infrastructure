#!/usr/bin/env bash
# terraform/envs/localのoutputsを `export TF_OUT_<NAME>=<value>` 形式で
# 標準出力に書き出す。`make e2e`からE2Eテストの実行環境変数として利用する。
#
# Usage: scripts/tf-outputs-env.sh
#   source <(scripts/tf-outputs-env.sh)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/../terraform/envs/local"

terraform -chdir="$TF_DIR" output -json | jq -r '
  to_entries[]
  | "export TF_OUT_\(.key | ascii_upcase)=\(.value.value | tostring | @sh)"
'
