#!/bin/sh
# Claude Code status line: model | cost | context % | duration
input=$(cat)

pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | awk '{printf "%.0f", $1}')
used=$(echo "$input" | jq -r '((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0))')
total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

# Format token counts as K
used_k=$(echo "$used" | awk '{printf "%.0fK", $1/1000}')
total_k=$(echo "$total" | awk '{printf "%.0fK", $1/1000}')

dur_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
dur_s=$((dur_ms / 1000))
mins=$((dur_s / 60))
secs=$((dur_s % 60))

printf "%s/%s (%s%%) ctx | %dm%02ds" "$used_k" "$total_k" "$pct" "$mins" "$secs"
