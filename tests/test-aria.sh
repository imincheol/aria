#!/usr/bin/env bash
# ARIA 기본 기능 테스트
export PATH="$HOME/.aria/bin:$PATH"

PASS=0; FAIL=0

run_test() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  ✅ $name"; PASS=$((PASS+1))
  else
    echo "  ❌ $name"; FAIL=$((FAIL+1))
  fi
}

check_output() {
  local cmd="$1" pattern="$2"
  $cmd 2>&1 | grep -q "$pattern"
}

echo "=== ARIA Test Suite ==="
run_test "aria version" check_output "aria version" "v1"
run_test "aria status" check_output "aria status" "ARIA"
run_test "aria nyx list" check_output "aria nyx list" "Agents"
run_test "aria nyx archetypes" check_output "aria nyx archetypes" "Archetypes"
run_test "aria nyx teams" check_output "aria nyx teams" "Presets"
run_test "aria khala list" check_output "aria khala list" "Khala"
run_test "aria registry runtimes" check_output "aria registry runtimes" "Runtimes"
run_test "config.json valid" python3 -c "import json; json.load(open('$HOME/.aria/config.json'))"
run_test "agents.json valid" python3 -c "import json; d=json.load(open('$HOME/.aria/agents/agents.json')); assert len(d['agents'])>=5"
run_test "routing.json valid" python3 -c "import json; d=json.load(open('$HOME/.aria/nyx/routing.json')); assert len(d['rules'])>=5"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
