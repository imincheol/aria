---
name: arb
description: "Agent Runtime Bus — arb status, bus, knowledge, registry"
metadata:
  arb:
    version: "0.1.0"
---

# ARB — Agent Runtime Bus

Runtime 간 에이전트 통신 + 지식 공유.

## CLI

```bash
arb status                        # 전체 상태
arb bus publish <channel> <msg>   # 메시지 발행
arb bus tail <channel> [n]        # 최근 메시지
arb knowledge search <query>      # FTS5 검색
arb registry runtimes             # 런타임 목록
arb registry info <id>            # 상세 정보
```

## 경로

- App data: `~/.arb/`
- Project: `~/_/projects/agent-runtime-bus/`
