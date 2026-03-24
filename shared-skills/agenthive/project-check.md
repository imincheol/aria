# AgentHive Project Check Skill

## Purpose
AgentHive 프로젝트를 주기적으로 점검하고 후속 작업을 분기하는 스킬.
cron/deep-work 패턴으로 연속적인 작업 흐름 유지.

## When to Use
- "프로젝트 점검해", "상태 확인해"
- "주기적으로 체크해", "크론 걸어"
- "딥워크처럼 계속 전진시켜"

## Philosophy
- cron은 **감시자/분기자**다
- 무거운 구현은 cron이 직접 하지 않는다
- 상태는 AgentHive hub가 기억한다
- 실제 작업은 격리 세션/에이전트에게 위임한다

## Check Targets

1. `tasks/BACKLOG.md`
2. doing/review/blocked 상태 태스크
3. stale lock
4. summary 최신성
5. 최근 log 변화

## Recommended Flow

```
cron → 상태 읽기 → 이상 판단 → 격리 세션/에이전트 위임 → 기록
```
