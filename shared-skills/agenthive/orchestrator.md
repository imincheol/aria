# AgentHive Orchestrator Skill

## Purpose
현재 프로젝트 path 기준으로 AgentHive 프로젝트를 resolve하고,
적절한 에이전트에게 task를 분배하는 오케스트레이션 스킬.

## When to Use
- "현재 프로젝트 기준으로 하이브 작업 진행"
- "작업 맡겨", "오케스트레이팅해"
- task 분배, plan/build/review 흐름 정렬

## Role Separation
- **AgentHive**: source of truth (task, plan, summary, review, decision, log)
- **Orchestrator (this skill)**: 세션 생성, 에이전트 위임, 채널 보고
- **Dashboard**: 사람용 UI — 에이전트의 작업 source가 아님

## Procedure

### 1. Resolve Project
```
우선순위:
1. 명시적 project slug
2. 현재 작업 경로(cwd) → registry canonical path 매칭
3. 더 긴 경로 우선 매칭
4. 없으면 수동 선택 또는 첫 프로젝트 fallback
```

### 2. Read Hub State
최소 확인 항목:
- `project.yaml` — 프로젝트 메타 + active_agents
- `tasks/BACKLOG.md` — 태스크 인덱스
- 관련 task의 `task.yaml`, `plan.md`, `summary.md`
- 필요 시 `log/`, `decisions/`

### 3. Classify Work
- 짧은 문서화/정리/판단: 현재 세션
- 코딩/리팩터링: Claude Code / Codex에 위임
- 장기/반복 점검: cron 또는 deep-work 패턴으로 분리

### 4. Delegate
위임 시 포함할 최소 맥락:
- 프로젝트 경로 + slug
- task id / title
- scope + acceptance
- 현재 상태(summary)
- 건드리면 안 되는 영역

### 5. Agent Recommendations
| Agent | Best For |
|-------|----------|
| Claude Code | 구조 설계, 대형 코드 수정, 리팩터링 |
| Codex | 빠른 구현, 테스트, 유틸 로직 |
| Cursor | 프론트엔드, UI, 실험성 작업 |
| AntiGravity | IDE 통합 작업 |
| OpenClaw | 오케스트레이션, cron, 멀티에이전트 |

## Rules
- Dashboard를 source of truth로 쓰지 않는다
- project resolve 없이 임의 프로젝트에 쓰지 않는다
- plan 없는 구현을 기본 흐름으로 만들지 않는다
- 외부 발신은 사람 확인 없이 실행하지 않는다
