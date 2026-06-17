#!/usr/bin/env bash
# PostToolUse: .tfファイルの編集後に terraform fmt を自動実行する
# Claude Codeがファイルを編集するたびにfmtを適用し、PR時のfmt-check失敗を防ぐ

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if echo "$FILE_PATH" | grep -q '\.tf$'; then
  DIR="$(dirname "$FILE_PATH")"
  if command -v terraform &>/dev/null; then
    terraform fmt "$DIR" 2>&1 || true
  fi
fi
