#!/usr/bin/env bash
# token-telemetry.sh
# PostToolUse hook on all tools. Appends a one-line entry per tool call to
# docs/agent-runs.log so you can analyze token spend after the fact.
#
# This produces NO direct savings. It enables measurement, which is the
# prerequisite for tuning. Without telemetry you're guessing at where
# tokens go.
#
# Log format (TSV):
#   ISO8601  session_id  tool_name  approx_input_tokens  approx_output_tokens  cwd
#
# Tokens are approximated as chars/4 (rough English heuristic). For exact
# accounting, use Anthropic's API usage dashboard.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input=$(cat)

# Pull fields. Default to empty so the line is parseable even if a field is missing.
session_id=$(echo "$input" | jq -r '.session_id // ""')
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')

# Approximate tokens.
input_size=$(echo "$input" | jq -r '.tool_input // {} | tostring | length')
output_size=$(echo "$input" | jq -r '.tool_response // {} | tostring | length')
input_tokens=$((input_size / 4))
output_tokens=$((output_size / 4))

# Where to log. Use cwd's docs/ if it exists, else fall back to ~/.claude/.
if [ -d "$cwd/docs" ]; then
  log_file="$cwd/docs/agent-runs.log"
elif [ -d "$HOME/.claude" ]; then
  log_file="$HOME/.claude/agent-runs.log"
else
  exit 0
fi

# Don't error if the log directory is read-only.
{
  printf "%s\t%s\t%s\t%d\t%d\t%s\n" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$session_id" \
    "$tool_name" \
    "$input_tokens" \
    "$output_tokens" \
    "$cwd" \
    >> "$log_file"
} 2>/dev/null || true

# This hook produces no Claude-visible output — it's pure telemetry.
exit 0
