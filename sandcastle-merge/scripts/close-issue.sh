#!/usr/bin/env bash
# Usage: bash close-issue.sh <ISSUE_ID>
# Closes the given GitHub issue. If ISSUE_ID is empty, does nothing.

ISSUE_ID="${1:-}"

if [ -z "$ISSUE_ID" ]; then
  echo "ℹ No issue ID provided — skipping issue close."
  exit 0
fi

gh issue close "$ISSUE_ID" --comment "Completed by Sandcastle and merged to main."
echo "✔ Closed issue #$ISSUE_ID."
