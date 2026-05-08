#!/usr/bin/env bash
# bash-output-discipline.sh
# PostToolUse hook on Bash. Detects large stdout/stderr outputs and injects
# a system reminder telling Claude to use targeted commands (head/tail/grep/awk)
# next time, and to consider /compact if context is filling up.
#
# This is ADVISORY only — Claude Code hooks cannot modify the tool result the
# model already received. We can only add a system message that Claude will
# see on its next turn. Use that message to nudge better discipline.

set -euo pipefail

# Thresholds — tunable.
MAX_LINES=200
MAX_CHARS=10000

# jq is required to parse the input JSON. Fail soft.
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Read the hook input from stdin.
input=$(cat)

# Extract stdout from the tool response.
stdout=$(echo "$input" | jq -r '.tool_response.stdout // ""')
stderr=$(echo "$input" | jq -r '.tool_response.stderr // ""')

# Combine and measure.
combined="$stdout$stderr"
char_count=${#combined}
line_count=$(echo -n "$combined" | grep -c '^' || true)

# Only fire if output is genuinely large.
if [ "$char_count" -lt "$MAX_CHARS" ] && [ "$line_count" -lt "$MAX_LINES" ]; then
  exit 0
fi

# Build the reminder.
read -r -d '' MESSAGE <<EOF || true
TOKEN DISCIPLINE: That Bash output was $line_count lines / $char_count chars.

Next time:
- Use targeted commands. \`grep PATTERN file\` beats \`cat file\`. \`head -50\` / \`tail -50\` beat full dumps.
- For long logs, pipe through \`grep ERROR\` or \`tail -100\`.
- For \`git diff\` with many files, use \`--stat\` first, then drill into specific files.
- For \`find\` / \`ls -R\`, narrow with \`-name\` / \`-type\` / \`-maxdepth\`.

If context is filling up: run \`/compact\` at the next phase boundary.
EOF

# Emit a JSON response that Claude Code will surface as a system message.
jq -cn \
  --arg message "$MESSAGE" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $message}}'
