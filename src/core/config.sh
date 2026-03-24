#!/usr/bin/env bash
# ARIA Core — paths, constants, helpers

ARIA_HOME="${ARIA_HOME:-$HOME/.aria}"
ARIA_CONFIG="$ARIA_HOME/config.json"
ARIA_KHALA_DIR="$ARIA_HOME/khala/channels"
ARIA_KNOWLEDGE_DB="$ARIA_HOME/knowledge/main.sqlite"
ARIA_KNOWLEDGE_CLI="$ARIA_HOME/knowledge/lib/oc-knowledge.sh"
ARIA_REGISTRY="$ARIA_HOME/registry"
ARIA_AGENTS="$ARIA_HOME/agents"

aria_detect_runtime() {
  if [[ -n "${ARIA_RUNTIME:-}" ]]; then
    printf '%s\n' "$ARIA_RUNTIME"
    return
  fi

  case "${__CFBundleIdentifier:-}" in
    com.openai.codex)
      printf '%s\n' "codex"
      return
      ;;
    com.anthropic.claudefordesktop)
      printf '%s\n' "claude-app"
      return
      ;;
  esac

  if [[ -n "${CODEX_THREAD_ID:-}" || -n "${CODEX_SHELL:-}" || -n "${CODEX_INTERNAL_ORIGINATOR_OVERRIDE:-}" ]]; then
    printf '%s\n' "codex"
    return
  fi

  printf '%s\n' "claude-code"
}

ARIA_RUNTIME="$(aria_detect_runtime)"
ARIA_VERSION="1.0.0"

# Legacy compat
ARB_HOME="$ARIA_HOME"
ARB_CONFIG="$ARIA_CONFIG"
ARB_BUS_DIR="$ARIA_KHALA_DIR"
ARB_KNOWLEDGE_DB="$ARIA_KNOWLEDGE_DB"
ARB_KNOWLEDGE_CLI="$ARIA_KNOWLEDGE_CLI"
ARB_REGISTRY="$ARIA_REGISTRY"
ARB_RUNTIME="$ARIA_RUNTIME"
ARB_VERSION="$ARIA_VERSION"

die() { echo "ERROR: $*" >&2; exit 1; }

aria_ensure_home() {
  mkdir -p "$ARIA_HOME"/{khala/{channels,lib},knowledge/lib,registry/{runtimes,nodes},agents,nyx/prompts,skills,profiles,runtimes}
}

aria_json_field() {
  local file="$1" field="$2"
  python3 -c "import json; print(json.load(open('$file')).get('$field',''))" 2>/dev/null
}

# Aliases for backward compat
arb_ensure_home() { aria_ensure_home; }
arb_json_field() { aria_json_field "$@"; }
