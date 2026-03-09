#!/usr/bin/env bash
set -euo pipefail

DOCS_DIR="docs"

REPO_NAME="$(basename "$(git -C "$DOCS_DIR" rev-parse --show-toplevel)" | tr '.' '-')"
OUTPUT="${REPO_NAME}-docs_dump.txt"

git -C "$DOCS_DIR" ls-files | while read -r file; do
  FULL_PATH="$DOCS_DIR/$file"

  if file --mime "$FULL_PATH" | grep -q 'charset='; then
    echo "===== FILE: $file ====="
    cat "$FULL_PATH"
    echo
  fi
done > "$OUTPUT"

echo "Export completed -> $OUTPUT"