#!/usr/bin/env bash
# dedup-advisor.sh
# PreToolUse hook on Read|Grep|Glob. Computes a hash of the incoming
# tool_input, looks for a recent matching call in the session's dedup
# cache (written by dedup-tracker.sh), and warns if the exact same call
# was made within the last N entries.
#
# This is the closest Claude Code can get to OpenCode-DCP's tool-result
# deduplication. DCP modifies the API payload to deduplicate; here we can
# only warn the model BEFORE re-running. The model can still proceed if
# the file/state likely changed since the last call.
#
# Only fires for read-only tools (Read, Grep, Glob). Mutating tools and
# Bash are excluded — duplicate writes/builds are usually intentional.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

if command -v shasum >/dev/null 2>&1; then
  HASH_CMD="shasum -a 256"
elif command -v sha256sum >/dev/null 2>&1; then
  HASH_CMD="sha256sum"
else
  exit 0
fi

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // ""')
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
tool_input=$(echo "$input" | jq -c '.tool_input // {}')

[ -z "$session_id" ] && exit 0
[ -z "$tool_name" ] && exit 0

# Hash the canonical JSON of tool_input.
hash=$(echo -n "$tool_input" | $HASH_CMD | awk '{print $1}' | cut -c1-16)

cache_file="$HOME/.claude/dedup-cache/$session_id.log"
[ ! -f "$cache_file" ] && exit 0

# Look for a matching tool_name + hash in the cache.
# Only consider the last 50 entries (recency window).
match=$(tail -50 "$cache_file" | awk -F'\t' -v t="$tool_name" -v h="$hash" '$2 == t && $3 == h {print $1}' | tail -1)

if [ -z "$match" ]; then
  exit 0
fi

# Build advisory.
case "$tool_name" in
  Read)
    file_path=$(echo "$tool_input" | jq -r '.file_path // ""')
    target="file: $file_path"
    suggestion="Refer to the earlier Read result already in your context. Re-Read only if you suspect the file changed."
    ;;
  Grep)
    pattern=$(echo "$tool_input" | jq -r '.pattern // ""')
    target="pattern: $pattern"
    suggestion="The earlier Grep results are already in your context. Re-grep only if a file in scope was just modified."
    ;;
  Glob)
    pattern=$(echo "$tool_input" | jq -r '.pattern // ""')
    target="glob: $pattern"
    suggestion="The earlier Glob result is already in your context. Re-glob only if files were created/deleted since."
    ;;
  *)
    target="<unknown>"
    suggestion="Consider whether re-running is necessary."
    ;;
esac

read -r -d '' MESSAGE <<EOF || true
TOKEN DISCIPLINE — DEDUPE: You're about to run a $tool_name call ($target) that you already ran in this session at $match.

$suggestion

If you DO need to re-run (file changed, dependencies updated, etc.), proceed. If not, skip and use the prior result.
EOF

jq -cn \
  --arg message "$MESSAGE" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $message}}'
