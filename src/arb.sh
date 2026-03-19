#!/usr/bin/env bash
# arb — Agent Runtime Bus CLI
# https://github.com/user/agent-runtime-bus (TBD)
set -euo pipefail

# Resolve project root (works from symlink too)
ARB_SRC="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")"; pwd)"

# Source core + commands
source "$ARB_SRC/core/config.sh"
source "$ARB_SRC/commands/status.sh"
source "$ARB_SRC/commands/bus.sh"
source "$ARB_SRC/commands/knowledge.sh"
source "$ARB_SRC/commands/registry.sh"

cmd="${1:-help}"; shift || true

case "$cmd" in
  status)    cmd_status ;;
  bus)       cmd_bus "$@" ;;
  knowledge) cmd_knowledge "$@" ;;
  registry)  cmd_registry "$@" ;;
  version)   echo "arb v${ARB_VERSION}" ;;
  help|--help|-h)
    cat <<'HELP'
arb — Agent Runtime Bus CLI

  arb status                        Health check
  arb bus publish <ch> <msg>        Publish message
  arb bus list                      List channels
  arb bus tail <ch> [n]             Recent messages
  arb knowledge search <q> [limit]  FTS5 search
  arb knowledge store <text>        Store knowledge
  arb knowledge stats               Stats
  arb registry runtimes             List runtimes
  arb registry nodes                List nodes
  arb registry agents               List agents
  arb registry info <id>            Details
  arb version                       Version
HELP
    ;;
  *) die "Unknown: $cmd (try: arb help)" ;;
esac
