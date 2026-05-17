#!/usr/bin/env bash
set -euo pipefail

echo "## Open Sandcastle issues"
echo
gh issue list \
  --state open \
  --label Sandcastle \
  --json number,title,body,labels,comments \
  --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'

echo
echo "## Recent RALPH commits (last 10)"
echo
git log --oneline --grep="RALPH" -10
