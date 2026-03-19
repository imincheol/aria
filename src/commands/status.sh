#!/usr/bin/env bash
# aria status — health check

cmd_status() {
  echo "=== ARIA (Agent-Runtime Integration Architecture) v${ARIA_VERSION} ==="
  echo ""

  [[ -f "$ARIA_CONFIG" ]] && echo "  Config:     OK" || echo "  Config:     MISSING"

  if [[ -f "$ARIA_KNOWLEDGE_DB" ]]; then
    local chunks
    chunks=$(sqlite3 "$ARIA_KNOWLEDGE_DB" "SELECT count(*) FROM chunks" 2>/dev/null || echo "?")
    echo "  Knowledge:  $chunks chunks"
  else
    echo "  Knowledge:  NOT LINKED"
  fi

  local ch_count=0 msg_count=0
  if [[ -d "$ARIA_KHALA_DIR" ]]; then
    for f in "$ARIA_KHALA_DIR"/**/*.jsonl; do
      [[ -f "$f" ]] || continue
      ch_count=$((ch_count + 1))
      msg_count=$((msg_count + $(wc -l < "$f" | tr -d ' ')))
    done
    echo "  Khala:      $ch_count channels, $msg_count messages"
  else
    echo "  Khala:      NOT LINKED"
  fi

  local rt_count=0 nd_count=0
  [[ -d "$ARIA_REGISTRY/runtimes" ]] && rt_count=$(ls "$ARIA_REGISTRY/runtimes/"*.json 2>/dev/null | wc -l | tr -d ' ')
  [[ -d "$ARIA_REGISTRY/nodes" ]] && nd_count=$(ls "$ARIA_REGISTRY/nodes/"*.json 2>/dev/null | wc -l | tr -d ' ')
  echo "  Runtimes:   $rt_count"
  echo "  Nodes:      $nd_count"

  # Nyx agents
  local nyx_count=0
  if [[ -d "$ARIA_AGENTS" ]]; then
    for d in "$ARIA_AGENTS"/*/; do
      [[ -f "$d/AGENT.md" ]] && nyx_count=$((nyx_count + 1))
    done
  fi
  echo "  Nyx Agents: $nyx_count"

  # Inference
  local ollama_url
  ollama_url=$(python3 -c "
import json
c = json.load(open('$ARIA_CONFIG'))
print(c.get('inference',{}).get('primary',{}).get('base_url',''))
" 2>/dev/null)
  if [[ -n "$ollama_url" ]]; then
    echo ""
    echo "--- Inference ---"
    if curl -s --connect-timeout 2 "$ollama_url/" >/dev/null 2>&1; then
      echo "  Ollama:     ONLINE ($ollama_url)"
    else
      echo "  Ollama:     OFFLINE ($ollama_url)"
    fi
  fi
}
