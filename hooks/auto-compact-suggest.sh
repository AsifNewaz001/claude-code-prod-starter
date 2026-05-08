#!/usr/bin/env bash
# auto-compact-suggest.sh
# PostToolUse hook on every tool. Sums the session's tool I/O tokens from
# docs/agent-runs.log (written by token-telemetry.sh) and suggests /compact
# when the session crosses configurable thresholds.
#
# This is the closest Claude Code can get to OpenCode-DCP's automatic
# trigger. DCP exposes a `compress` tool the model picks; here we only
# nudge the user (or the model) toward `/compact <focus>` when it's needed.
#
# Thresholds (sum of input + output tool tokens for this session):
#   - 75000  → suggest light compact at next phase boundary
#   - 150000 → suggest immediate compact
#
# Re-fire suppression: each threshold fires at most once per session via a
# marker file under /tmp.

set -euo pipefail

THRESHOLD_SOFT=75000
THRESHOLD_HARD=150000

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')

[ -z "$session_id" ] && exit 0

# Locate the telemetry log (same logic as token-telemetry.sh).
if [ -f "$cwd/docs/agent-runs.log" ]; then
  log_file="$cwd/docs/agent-runs.log"
elif [ -f "$HOME/.claude/agent-runs.log" ]; then
  log_file="$HOME/.claude/agent-runs.log"
else
  exit 0
fi

# Sum input + output tokens for this session.
total=$(awk -F'\t' -v sid="$session_id" '$2 == sid {sum += $4 + $5} END {print sum + 0}' "$log_file")

# Below soft threshold → silent.
if [ "$total" -lt "$THRESHOLD_SOFT" ]; then
  exit 0
fi

# Marker file path.
marker_dir="${TMPDIR:-/tmp}/cc-prod-starter"
mkdir -p "$marker_dir" 2>/dev/null || true

# Hard threshold takes priority.
if [ "$total" -ge "$THRESHOLD_HARD" ]; then
  marker="$marker_dir/compact-hard-$session_id"
  if [ -f "$marker" ]; then
    exit 0
  fi
  touch "$marker"

  read -r -d '' MESSAGE <<EOF || true
TOKEN DISCIPLINE — HARD THRESHOLD: This session has ~${total} tokens of tool I/O. Context is bloated.

Run /compact NOW with a focus argument:

  /compact focus on the current phase; drop completed tool dumps and verbose outputs

If you're mid-task: finish the current step, then compact. Don't compact mid-flow.

After compact, the next API turn will pay one cache miss but subsequent turns will be much cheaper.
EOF

else
  # Soft threshold.
  marker="$marker_dir/compact-soft-$session_id"
  if [ -f "$marker" ]; then
    exit 0
  fi
  touch "$marker"

  read -r -d '' MESSAGE <<EOF || true
TOKEN DISCIPLINE — soft threshold: This session has ~${total} tokens of tool I/O.

At your NEXT phase boundary (debugging loop closes, gate ends, requirements gathered):

  /compact focus on <what just ended>; keep <what's load-bearing>; drop <large tool outputs>

Don't compact mid-task. Compact at boundaries. The 5-minute prompt-cache TTL means one cache miss buys long savings if the session continues.
EOF
fi

jq -cn \
  --arg message "$MESSAGE" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $message}}'
