#!/usr/bin/env bash
# arb bus — channel messaging

cmd_bus() {
  local sub="${1:-help}"; shift || true
  case "$sub" in
    publish)  _bus_publish "$@" ;;
    list)     _bus_list ;;
    tail)     _bus_tail "$@" ;;
    *)        echo "Usage: arb bus {publish|list|tail}" ;;
  esac
}

_bus_publish() {
  local channel="${1:?Usage: arb bus publish <channel> <message>}"
  local message="${2:?Usage: arb bus publish <channel> <message>}"
  local from_runtime="${3:-$ARB_RUNTIME}"

  local channel_file="$ARB_BUS_DIR/${channel}.jsonl"
  mkdir -p "$(dirname "$channel_file")"

  local ts; ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local msg_id="arb-$(date +%Y%m%d-%H%M%S)-${from_runtime}"

  python3 -c "
import json, sys
print(json.dumps({
    'id': '$msg_id', 'channel': '$channel',
    'from': {'runtime': '$from_runtime', 'agent': 'main'},
    'type': 'message', 'content': sys.argv[1],
    'priority': 'normal', 'timestamp': '$ts', 'ttl': 86400
}, ensure_ascii=False))
" "$message" >> "$channel_file"
  echo "Published to $channel from $from_runtime"
}

_bus_list() {
  echo "=== ARB Channels ==="
  for f in "$ARB_BUS_DIR"/**/*.jsonl; do
    [[ -f "$f" ]] || continue
    local ch; ch=$(echo "$f" | sed "s|$ARB_BUS_DIR/||;s/\.jsonl$//")
    printf "  %-35s %s msgs\n" "$ch" "$(wc -l < "$f" | tr -d ' ')"
  done
}

_bus_tail() {
  local channel="${1:?Usage: arb bus tail <channel> [count]}"
  local count="${2:-5}"
  local channel_file="$ARB_BUS_DIR/${channel}.jsonl"
  [[ -f "$channel_file" ]] || die "Channel not found: $channel"

  echo "=== Last $count: $channel ==="
  tail -n "$count" "$channel_file" | python3 -c "
import json, sys
for line in sys.stdin:
    try:
        m = json.loads(line)
        fr = m.get('from', {})
        src = fr.get('runtime', fr.get('node', fr.get('instance', '?')))
        print(f'  [{m.get(\"timestamp\",\"?\")}] {src}: {m.get(\"content\",\"\")[:120]}')
    except: print(f'  {line.strip()}')" 2>/dev/null
}
