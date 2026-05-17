#!/usr/bin/env bash
set -euo pipefail

ID="${1:-}"

if [[ -z "$ID" ]]; then
  echo "❌ Usage: ./scripts/close-issue.sh <issue-number>" >&2
  exit 1
fi

gh issue close "$ID" --comment "Completed by Sandcastle"
echo "✅ Closed issue #$ID"
