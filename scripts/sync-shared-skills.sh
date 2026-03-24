#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.."; pwd)"
AGENT_HOME="${AGENT_HOME:-$HOME/.agent}"
ARIA_HOME="${ARIA_HOME:-$HOME/.aria}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

SHARED_ROOT="$AGENT_HOME/skills"
AGENT_CONFIG_DIR="$AGENT_HOME/config"
GENERATED_MANIFEST="$AGENT_CONFIG_DIR/skills-manifest.generated.yaml"
PRIMARY_MANIFEST="$AGENT_CONFIG_DIR/skills-manifest.yaml"

mkdir -p "$SHARED_ROOT" "$AGENT_CONFIG_DIR" \
  "$CODEX_HOME/skills" "$CLAUDE_HOME/skills" \
  "$ARIA_HOME/runtimes/codex/skills" "$ARIA_HOME/runtimes/claude-code/skills"

declare -a PORTABLE_ITEMS=(
  "agenthive/orchestrator.md|$PROJECT_DIR/shared-skills/agenthive/orchestrator.md"
  "agenthive/project-check.md|$PROJECT_DIR/shared-skills/agenthive/project-check.md"
  "agenthive/task-protocol.md|$PROJECT_DIR/shared-skills/agenthive/task-protocol.md"
)

declare -a OPTIONAL_ITEMS=(
  "github|$HOME/_/open-source/openclaw/skills/github"
  "session-logs|$HOME/_/open-source/openclaw/skills/session-logs"
  "summarize|$HOME/_/open-source/openclaw/skills/summarize"
  "llm-calab-bridge|$HOME/.codex/skills/llm-calab-bridge"
)

link_entry() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
}

add_manifest_entry() {
  local rel="$1"
  local source="$2"
  local shared="$3"
  cat >> "$GENERATED_MANIFEST" <<EOF
  - name: $(basename "$rel")
    class: portable
    source: "$source"
    shared_path: "$shared"
    consumers:
      - tool: codex
        path: "$CODEX_HOME/skills/$rel"
      - tool: claude
        path: "$CLAUDE_HOME/skills/$rel"
      - tool: aria-codex-runtime
        path: "$ARIA_HOME/runtimes/codex/skills/$rel"
      - tool: aria-claude-runtime
        path: "$ARIA_HOME/runtimes/claude-code/skills/$rel"
EOF
}

cat > "$GENERATED_MANIFEST" <<EOF
version: "1.1"
updated_at: "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
shared_root: "$SHARED_ROOT"
consumers:
  codex: "$CODEX_HOME/skills"
  claude: "$CLAUDE_HOME/skills"
  aria_codex_runtime: "$ARIA_HOME/runtimes/codex/skills"
  aria_claude_runtime: "$ARIA_HOME/runtimes/claude-code/skills"
skills:
EOF

for item in "${PORTABLE_ITEMS[@]}"; do
  rel="${item%%|*}"
  source="${item#*|}"
  [[ -e "$source" ]] || continue
  shared="$SHARED_ROOT/$rel"
  link_entry "$source" "$shared"
  link_entry "$shared" "$CODEX_HOME/skills/$rel"
  link_entry "$shared" "$CLAUDE_HOME/skills/$rel"
  link_entry "$shared" "$ARIA_HOME/runtimes/codex/skills/$rel"
  link_entry "$shared" "$ARIA_HOME/runtimes/claude-code/skills/$rel"
  add_manifest_entry "$rel" "$source" "$shared"
done

for item in "${OPTIONAL_ITEMS[@]}"; do
  rel="${item%%|*}"
  source="${item#*|}"
  [[ -e "$source" ]] || continue
  shared="$SHARED_ROOT/$rel"
  link_entry "$source" "$shared"
  link_entry "$shared" "$CODEX_HOME/skills/$rel"
  link_entry "$shared" "$CLAUDE_HOME/skills/$rel"
  link_entry "$shared" "$ARIA_HOME/runtimes/codex/skills/$rel"
  link_entry "$shared" "$ARIA_HOME/runtimes/claude-code/skills/$rel"
  add_manifest_entry "$rel" "$source" "$shared"
done

if [[ ! -f "$PRIMARY_MANIFEST" ]]; then
  cp "$GENERATED_MANIFEST" "$PRIMARY_MANIFEST"
fi

echo "Shared skill sync complete."
echo "  generated manifest: $GENERATED_MANIFEST"
echo "  primary manifest:   $PRIMARY_MANIFEST"
echo "  shared root:        $SHARED_ROOT"
