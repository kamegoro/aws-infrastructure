#!/usr/bin/env bash
# PreToolUse: センシティブファイル（.env/.pem/.key）への書き込みをブロックする
# exit 2 でClaude Codeのツール実行を強制拒否する

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if echo "$FILE_PATH" | grep -qE '\.(env|pem|key)$'; then
  echo "ERROR: センシティブファイルへの書き込みはブロックされています: $FILE_PATH" >&2
  exit 2
fi
