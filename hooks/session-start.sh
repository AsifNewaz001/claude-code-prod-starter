#!/usr/bin/env bash
# claude-code-prod-starter SessionStart hook.
# Injects the using-prod-starter dispatcher skill into every new session
# so Claude knows which skills, agents, and commands ship with this plugin
# and when to invoke them.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
DISPATCHER="$PLUGIN_ROOT/skills/using-prod-starter/SKILL.md"

# jq is required to emit valid JSON. If it's missing, fail soft so the plugin
# still works — skills will just have to be discovered manually.
if ! command -v jq >/dev/null 2>&1; then
  echo '{"priority": "INFO", "message": "claude-code-prod-starter: jq not found on PATH. Install jq (brew install jq | apt-get install jq) to enable auto-loading of the dispatcher skill. Skills remain available individually via the Skill tool."}'
  exit 0
fi

if [ ! -f "$DISPATCHER" ]; then
  echo '{"priority": "INFO", "message": "claude-code-prod-starter: dispatcher skill not found. Skills may still be available individually."}'
  exit 0
fi

CONTENT=$(cat "$DISPATCHER")

jq -cn \
  --arg message "claude-code-prod-starter loaded. Use the dispatcher below to find the right skill, agent, or command for the task at hand.

$CONTENT" \
  '{priority: "IMPORTANT", message: $message}'
