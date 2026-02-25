#!/usr/bin/env bash
set -euo pipefail

OUTPUT="repo_dump.md"
DOCS_DIR="docs"

{
  echo "# Repository Export (docs/)"
  echo
  echo "Generated on: $(date)"
  echo
  echo "---"
  echo
  echo "## 📑 Index"
  echo

  # Índice
  git -C "$DOCS_DIR" ls-files | while read -r file; do
    echo "- docs/$file"
  done

  echo
  echo "---"
  echo

  # Contenido
  git -C "$DOCS_DIR" ls-files | while read -r file; do
    FULL_PATH="$DOCS_DIR/$file"

    if file --mime "$FULL_PATH" | grep -q 'charset='; then
      ext="${file##*.}"
      lang="$ext"
      [ "$ext" = "$file" ] && lang="text"

      echo "## 📄 docs/$file"
      echo
      echo "\`\`\`$lang"
      cat "$FULL_PATH"
      echo
      echo "\`\`\`"
      echo
      echo "---"
      echo
    fi
  done

} > "$OUTPUT"

echo "Export completed → $OUTPUT"