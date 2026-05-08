#!/usr/bin/env bash
# subagent-discipline.sh
# PreToolUse hook on the Agent tool. Injects a system reminder before every
# subagent spawn telling Claude to use a tight context bundle pattern (static
# refs by path + dynamic delta + budget reminder), not "read everything."
#
# Subagent spawn prompts are one of the highest-leverage token-saving levers.
# A 2k-token bundle that sets up the child correctly beats a 10k-token
# "read AGENTS.md and all the docs" dump every time.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input=$(cat)

# Try to read the prompt the spawner is about to send.
prompt=$(echo "$input" | jq -r '.tool_input.prompt // ""')
prompt_chars=${#prompt}

# Build advice based on prompt size.
# < 2000 chars = good, no nag.
# 2000-5000 = mild reminder.
# > 5000 = strong reminder.
if [ "$prompt_chars" -lt 2000 ]; then
  exit 0
fi

if [ "$prompt_chars" -lt 5000 ]; then
  TIER="mild"
  HEADLINE="Subagent prompt is $prompt_chars chars. Acceptable but tighten if you can."
else
  TIER="strong"
  HEADLINE="Subagent prompt is $prompt_chars chars — that's a lot of tokens to pay every spawn."
fi

read -r -d '' MESSAGE <<EOF || true
TOKEN DISCIPLINE ($TIER): $HEADLINE

Tight bundle pattern (target <2000 chars):

1. Static refs (link by path; child reads on demand, doesn't re-pay):
   "Read these on demand: PROJECT_CONTEXT.md, docs/foo.md, ..."

2. Dynamic delta (paste verbatim — only what's NEW for this gate):
   "Build SHA: abc123. Files changed: <git diff --stat snippet>. Conditions from prior gate: ..."

3. Budget + output format:
   "Your budget: 60k tokens. End with verdict block."

If you're already inside a tight bundle and just briefing the subagent, ignore. If you're pasting whole docs into the prompt, rewrite as static refs.
EOF

jq -cn \
  --arg message "$MESSAGE" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $message}}'
