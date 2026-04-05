#!/bin/bash

# Read JSON input
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | sed -n 's/.*"current_dir":"\([^"]*\)".*/\1/p')
model=$(echo "$input" | sed -n 's/.*"model":{"id":"\([^"]*\)".*/\1/p')
api_wait=$(echo "$input" | sed -n 's/.*"api_wait_time_ms":\([0-9]*\).*/\1/p')

# Get context percentage from ccstatusline
context_pct=$(echo "$input" | npx ccstatusline)

# Get Node version
node_version=$(node -v 2>/dev/null | sed 's/^v//')

# Git information
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  # Get repo name relative to ~/Desktop/dev/
  repo_name=$(echo "$cwd" | sed "s|^$HOME/Desktop/dev/||")

  # Get branch
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Check if dirty (has uncommitted changes)
  if git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null; then
    dirty=""
  else
    dirty=" "$'\e[0m\e[1m\e[38;5;3m✗\e[0m'
  fi

  # robbyrussell format: ➜ directory git:(branch) ✗
  output=$'\e[0m\e[1m\e[38;5;2m➜\e[0m \e[0m\e[38;5;6m'"$repo_name"$'\e[0m \e[0m\e[1m\e[38;5;4mgit:(\e[0m\e[0m\e[38;5;1m'"$branch"$'\e[0m\e[0m\e[38;5;4m)\e[0m'"$dirty"
else
  # Not a git repo
  output=$'\e[0m\e[1m\e[38;5;2m➜\e[0m \e[0m\e[38;5;6m'"$cwd"$'\e[0m'
fi

# Model (abbreviated) in magenta
if [ -n "$model" ]; then
  case "$model" in
    claude-opus-4-6|opus) model_short="opus" ;;
    claude-sonnet-4-6|sonnet) model_short="sonnet" ;;
    claude-haiku-4-5|haiku) model_short="haiku" ;;
    glm-5) model_short="glm-5" ;;
    *) model_short="$model" ;;
  esac
  output="$output "$'\e[0m\e[38;5;5m'"$model_short"$'\e[0m'
fi

# API wait time in white (only show if > 0)
if [ -n "$api_wait" ] && [ "$api_wait" -gt 0 ]; then
  output="$output "$'\e[0m\e[38;5;7m'"${api_wait}ms"$'\e[0m'
fi

# Context percentage in yellow
if [ -n "$context_pct" ]; then
  output="$output "$'\e[0m\e[38;5;3m'"$context_pct"$'\e[0m'
fi

# Node version in green
if [ -n "$node_version" ]; then
 output="$output "$'\e[0m\e[38;5;2m'"[node:$node_version]"$'\e[0m'
fi

printf '%s' "$output"
