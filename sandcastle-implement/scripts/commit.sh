#!/usr/bin/env bash
set -euo pipefail

MSG="${1:-}"

if [[ -z "$MSG" ]]; then
  echo "❌ Usage: ./scripts/commit.sh \"<commit message>\"" >&2
  exit 1
fi

if [[ "$MSG" != RALPH:* ]]; then
  echo "❌ Commit message must start with 'RALPH:' prefix." >&2
  exit 1
fi

# Safety net: verify before committing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "▶ Running verification before commit..."
"$SCRIPT_DIR/verify.sh"

git add -A
git commit -m "$MSG"
echo "✅ Committed: $(git rev-parse --short HEAD)"
