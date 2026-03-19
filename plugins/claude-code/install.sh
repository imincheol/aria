#!/usr/bin/env bash
# ARB Plugin: Claude Code
# Installs hooks and skill into Claude Code configuration
set -euo pipefail

ARB_HOME="${1:-$HOME/.arb}"
PLUGIN_DIR="$(cd "$(dirname "$0")"; pwd)"
CLAUDE_HOME="$HOME/.claude"

echo "    [claude-code] Setting up ARB integration..."

# 1. Register as runtime
cat > "$ARB_HOME/registry/runtimes/claude-code.json" <<JSON
{
  "id": "claude-code",
  "type": "runtime",
  "name": "Claude Code",
  "host": "$(hostname -s)",
  "capabilities": ["code-generation", "code-review", "orchestration", "knowledge-search", "bus-publish"],
  "inference": { "primary": "anthropic/claude-opus-4-6", "local": "ollama/qwen3.5:35b-a3b" },
  "status": "active",
  "registered_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

# 2. Install skill (if Claude Code skills dir exists)
if [[ -d "$HOME/.openclaw/skills" ]]; then
  skill_dir="$HOME/.openclaw/skills/arb"
  mkdir -p "$skill_dir"
  if [[ -d "$PLUGIN_DIR/skill" ]] && ls "$PLUGIN_DIR/skill/"* >/dev/null 2>&1; then
    cp -r "$PLUGIN_DIR/skill/"* "$skill_dir/"
    echo "    [claude-code] Skill installed at $skill_dir"
  fi
fi

echo "    [claude-code] Runtime registered, integration ready"
