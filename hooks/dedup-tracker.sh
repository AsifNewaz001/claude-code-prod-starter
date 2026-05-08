#!/usr/bin/env bash
# dedup-tracker.sh
# PostToolUse hook on Read|Grep|Glob. Records a hash of the tool_input to
# a per-session dedup cache so dedup-advisor.sh can warn when the same
# call is about to be made again.
#
# Pure side effect. No Claude-visible output.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Hash util (use shasum which is on macOS, sha256sum on linux).
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

# Cache directory.
cache_dir="$HOME/.claude/dedup-cache"
mkdir -p "$cache_dir" 2>/dev/null || true
cache_file="$cache_dir/$session_id.log"

# Append: timestamp \t tool_name \t hash
{
  printf "%s\t%s\t%s\n" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$tool_name" \
    "$hash" \
    >> "$cache_file"
} 2>/dev/null || true

# Trim to last 100 lines to bound disk use.
if [ -f "$cache_file" ]; then
  tail -100 "$cache_file" > "$cache_file.tmp" 2>/dev/null && mv "$cache_file.tmp" "$cache_file" 2>/dev/null || true
fi

exit 0
