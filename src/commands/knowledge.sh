#!/usr/bin/env bash
# arb knowledge — FTS5 knowledge base

cmd_knowledge() {
  local sub="${1:-help}"; shift || true
  [[ -x "$ARB_KNOWLEDGE_CLI" ]] || die "Knowledge CLI not linked: $ARB_KNOWLEDGE_CLI"
  case "$sub" in
    search|store|stats|agents) exec "$ARB_KNOWLEDGE_CLI" "$sub" "$@" ;;
    *) echo "Usage: arb knowledge {search|store|stats|agents}" ;;
  esac
}
