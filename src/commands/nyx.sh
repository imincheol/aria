#!/usr/bin/env bash
# aria nyx — Nyx agent management

ARIA_ARCHETYPES="$ARIA_HOME/profiles/archetypes"
ARIA_TEAMS="$ARIA_HOME/profiles/teams"

cmd_nyx() {
  local sub="${1:-help}"; shift || true
  case "$sub" in
    list)       _nyx_list ;;
    info)       _nyx_info "$@" ;;
    archetypes) _nyx_archetypes "$@" ;;
    teams)      _nyx_teams ;;
    *)          echo "Usage: aria nyx {list|info <id>|archetypes [category]|teams}" ;;
  esac
}

_nyx_list() {
  echo "=== Nyx Agents ==="
  local count=0
  for dir in "$ARIA_AGENTS"/*/; do
    [[ -d "$dir" ]] || continue
    local id; id=$(basename "$dir")
    local agent_md="$dir/AGENT.md"
    local config_json="$dir/config.json"
    local has_harness="N"; [[ -d "$dir/harness" ]] && has_harness="Y"
    local has_memory="N"; [[ -f "$dir/memory/context.md" ]] && has_memory="Y"
    local nyx_type="unknown"
    if [[ -f "$config_json" ]]; then
      nyx_type=$(python3 -c "import json; print(json.load(open('$config_json')).get('type','unknown'))" 2>/dev/null || echo "unknown")
    fi
    local desc=""
    if [[ -f "$agent_md" ]]; then
      desc=$(head -1 "$agent_md" | sed 's/^# //' | cut -c1-50)
    fi
    printf "  %-20s %-10s harness:%-1s mem:%-1s  %s\n" "$id" "$nyx_type" "$has_harness" "$has_memory" "$desc"
    count=$((count + 1))
  done
  echo ""
  echo "  Total: $count agents"
}

_nyx_archetypes() {
  local category="${1:-all}"
  echo "=== Archetypes ==="
  local count=0
  local dirs=()
  if [[ "$category" == "all" ]]; then
    dirs=("$ARIA_ARCHETYPES"/dev "$ARIA_ARCHETYPES"/art "$ARIA_ARCHETYPES"/persona "$ARIA_ARCHETYPES"/runtime-expert)
  else
    dirs=("$ARIA_ARCHETYPES/$category")
  fi
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    local cat_name; cat_name=$(basename "$dir")
    for f in "$dir"/*.md; do
      [[ -f "$f" ]] || continue
      local id; id=$(basename "$f" .md)
      local name; name=$(head -1 "$f" | sed 's/^# [^ ]* — //')
      printf "  %-12s %-24s %s\n" "[$cat_name]" "$id" "$name"
      count=$((count + 1))
    done
  done
  echo ""
  echo "  Total: $count archetypes"
}

_nyx_teams() {
  echo "=== Team Presets ==="
  local presets_file="$ARIA_TEAMS/presets.json"
  [[ -f "$presets_file" ]] || { echo "  No presets found"; return; }
  python3 -c "
import json
d = json.load(open('$presets_file'))
for p in d.get('presets', []):
    members = ', '.join(p.get('members', []))
    print(f\"  {p['id']:24s} {p['name']:20s} [{p.get('review_mode','?')}] {members[:60]}\")" 2>/dev/null
}

_nyx_info() {
  local id="${1:?Usage: aria nyx info <id>}"
  local agent_dir="$ARIA_AGENTS/$id"
  [[ -d "$agent_dir" ]] || die "Agent '$id' not found"

  echo "=== Nyx Agent: $id ==="
  if [[ -f "$agent_dir/config.json" ]]; then
    echo ""
    echo "--- Config ---"
    python3 -c "import json; print(json.dumps(json.load(open('$agent_dir/config.json')), indent=2, ensure_ascii=False))"
  fi
  if [[ -f "$agent_dir/AGENT.md" ]]; then
    echo ""
    echo "--- AGENT.md (first 20 lines) ---"
    head -20 "$agent_dir/AGENT.md"
  fi
  if [[ -f "$agent_dir/memory/context.md" ]]; then
    echo ""
    echo "--- Memory ---"
    head -15 "$agent_dir/memory/context.md"
  fi
}
