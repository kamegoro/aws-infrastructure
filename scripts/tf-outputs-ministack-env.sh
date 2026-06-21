#!/usr/bin/env bash
# terraform/envs/local の outputs から、task-canvas-e2e (Hoplite) が読む
# 環境変数を生成して標準出力に書き出す。
#
# Hoplite 2.x では __ がネストのセパレータになる:
#   TASK_CANVAS__REST__BASE_URL -> taskCanvas.rest.baseUrl
#
# Usage: source <(scripts/tf-outputs-ministack-env.sh)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/../terraform/envs/local"

# terraform outputs を変数に取得
ALB_DNS=$(terraform -chdir="$TF_DIR" output -raw alb_dns_name)
CF_DOMAIN=$(terraform -chdir="$TF_DIR" output -raw frontend_distribution_domain_name)
DB_ENDPOINT=$(terraform -chdir="$TF_DIR" output -raw db_endpoint)
DB_PORT=$(terraform -chdir="$TF_DIR" output -raw db_port)
DB_NAME=$(terraform -chdir="$TF_DIR" output -raw db_name)

cat <<EOF
export TASK_CANVAS__REST__BASE_URL="http://${ALB_DNS}"
export TASK_CANVAS_WEB__BACKEND_HOST="${ALB_DNS}"
export TASK_CANVAS_WEB__BACKEND_PORT="80"
export TASK_CANVAS__DB__JDBC_URL="jdbc:postgresql://${DB_ENDPOINT}:${DB_PORT}/${DB_NAME}"
export TASK_CANVAS__DB__USERNAME="task_canvas"
export TASK_CANVAS__DB__SCHEMA="task_canvas"
export SELENIDE__BASE_URL="http://${CF_DOMAIN}"
EOF
