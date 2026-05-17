#!/usr/bin/env bash
# Usage: bash merge.sh [BRANCH]
# If BRANCH is omitted, auto-detects the most recent sandcastle/impl/* branch
# from .sandcastle/worktrees/ or .claude/worktrees/.
# Then merges into current branch and runs typecheck + tests.
# Compatible with macOS (BSD) and Linux (GNU).

set -e

BRANCH="${1:-}"

# Portable mtime helper: prints "<epoch> <name>" for a directory
_mtime_entry() {
  local path="$1"
  local name
  name="$(basename "$path")"
  if stat -f "%m" "$path" >/dev/null 2>&1; then
    # BSD stat (macOS)
    echo "$(stat -f "%m" "$path") $name"
  else
    # GNU stat (Linux)
    echo "$(stat -c "%Y" "$path") $name"
  fi
}

# Auto-detect branch if not provided
if [ -z "$BRANCH" ]; then
  echo "▶ No branch provided — auto-detecting from worktrees..."

  WORKTREE_DIRS=(".sandcastle/worktrees" ".claude/worktrees")
  CANDIDATES=()

  for dir in "${WORKTREE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      while IFS= read -r name; do
        [ -n "$name" ] && CANDIDATES+=("$name")
      done < <(
        find "$dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null \
          | while read -r entry; do _mtime_entry "$entry"; done \
          | sort -rn \
          | awk '{print $2}'
      )
    fi
  done

  if [ ${#CANDIDATES[@]} -eq 0 ]; then
    echo "✖ No worktrees found in .sandcastle/worktrees/ or .claude/worktrees/."
    echo "  Pass the branch name explicitly: bash merge.sh <BRANCH>"
    exit 1
  fi

  LATEST="${CANDIDATES[0]}"
  BRANCH="sandcastle/impl/${LATEST}"

  if [ ${#CANDIDATES[@]} -gt 1 ]; then
    echo "⚠ Multiple worktrees detected. Using most recent: $BRANCH"
    echo "  Others found:"
    for ((i=1; i<${#CANDIDATES[@]}; i++)); do
      echo "    - sandcastle/impl/${CANDIDATES[$i]}"
    done
  else
    echo "✔ Detected branch: $BRANCH"
  fi
fi

# Verify branch exists
if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  echo "✖ Branch '$BRANCH' does not exist in this repository."
  exit 1
fi

echo "▶ Merging $BRANCH into $(git rev-parse --abbrev-ref HEAD)..."
if ! git merge "$BRANCH" --no-edit; then
  echo "✖ Merge conflicts detected. Resolve them, then re-run:"
  echo "    pnpm run typecheck && pnpm run test"
  exit 1
fi

echo "▶ Running typecheck..."
pnpm run typecheck

echo "▶ Running tests..."
pnpm run test

echo "✔ Merge complete and verified."
