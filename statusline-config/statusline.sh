#!/bin/sh
# Claude Code status line: robbyrussell-style prompt + context info
input=$(cat)

# Current working directory (basename only, like robbyrussell %c)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")

# Git branch (with --no-optional-locks to avoid interfering with git operations)
branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  if [ -n "$branch" ]; then
    dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  fi
fi

# Context window usage
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
# used_tokens doesn't exist; compute from current_usage fields
used=$(echo "$input" | jq -r '
  .context_window.current_usage
  | if . then
      ((.input_tokens // 0) + (.output_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
    else empty end
')
if [ -n "$used" ] && [ -n "$ctx_size" ]; then
  used_k=$(printf "%.0f" "$(echo "$used / 1000" | bc -l)")
  size_k=$(printf "%.0f" "$(echo "$ctx_size / 1000" | bc -l)")
  tokens_fmt="${used_k}k/${size_k}k"
  if [ -n "$ctx_pct" ]; then
    tokens_fmt="${tokens_fmt} (${ctx_pct}%)"
  fi
else
  tokens_fmt=""
fi

# Model
model=$(echo "$input" | jq -r 'if .model | type == "object" then .model.display_name // .model.id // empty elif .model then .model else empty end')

# Node version (cached to avoid running on every render)
node_ver=$(node -v 2>/dev/null | sed 's/^v//')

# Time waiting on API
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // empty')
if [ -n "$api_ms" ]; then
  api_sec=$(printf "%.0f" "$(echo "$api_ms / 1000" | bc -l)")
  if [ "$api_sec" -ge 60 ]; then
    api_min=$((api_sec / 60))
    api_rem=$((api_sec % 60))
    api_fmt="${api_min}m${api_rem}s"
  else
    api_fmt="${api_sec}s"
  fi
else
  api_fmt=""
fi

# ANSI colors (will be dimmed by Claude Code terminal)
CYAN='\033[0;36m'
BOLD_BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Build prompt: dir part
printf "${CYAN}%s${RESET}" "$dir"

# Git part: git:(branch) + dirty marker
if [ -n "$branch" ]; then
  printf " ${BOLD_BLUE}git:(${RED}%s${BOLD_BLUE})${RESET}" "$branch"
  if [ -n "$dirty" ]; then
    printf " ${YELLOW}✗${RESET}"
  fi
fi

# Extra info segments
DIM='\033[2m'

if [ -n "$model" ]; then
  printf " ${DIM}|${RESET} %s" "$model"
fi

if [ -n "$tokens_fmt" ]; then
  printf " ${DIM}|${RESET} %s" "$tokens_fmt"
fi

if [ -n "$api_fmt" ]; then
  printf " ${DIM}|${RESET} api %s" "$api_fmt"
fi

if [ -n "$node_ver" ]; then
  printf " ${DIM}|${RESET} node %s" "$node_ver"
fi
