# ARIA — Agent-Runtime Integration Architecture

> 각 런타임이 자신의 아리아를 부르면서 전체 오페라를 이룬다.

## ARIA란?

ARIA는 AI 에이전트와 런타임 환경을 통합 관리하는 오케스트레이션 시스템입니다. 에이전트 관리(Nyx), 런타임 간 통신(Khala), 공유 지식 베이스(Knowledge), 런타임/노드 발견(Registry)을 하나의 구조로 연결합니다.

## 설치

```bash
git clone https://github.com/songblaq/aria.git
cd aria
./install.sh
export PATH="$HOME/.aria/bin:$PATH"
aria status
```

## CLI 명령어

```bash
# 시스템
aria status                             # 전체 헬스체크
aria version                            # 버전

# Nyx — 에이전트
aria nyx list                           # 에이전트 목록
aria nyx info <id>                      # 에이전트 상세
aria nyx archetypes [카테고리]            # 리뷰 아키타입 목록
aria nyx teams                          # 팀 프리셋 목록

# Khala — 통신
aria khala list                         # 채널 목록
aria khala publish <채널> <메시지>        # 메시지 발행
aria khala tail <채널> [n]              # 최근 메시지

# Knowledge — 지식
aria knowledge search <쿼리> [limit]    # 전문 검색
aria knowledge store <텍스트>            # 지식 저장

# Registry — 등록
aria registry runtimes                  # 런타임 목록
aria registry nodes                     # 노드 목록
```

## Nyx 에이전트

### 에이전트 유형

| 유형 | 설명 | 영속 | 메모리 |
|------|------|------|--------|
| **Harness** | 외부 도구 래핑 (SSH, ComfyUI, API 등) | O | O |
| **Pure** | LLM 프롬프트만으로 동작 | O | O |
| **Creator** | 다른 에이전트 생성/관리 | O | O |
| **Phantom** | 에페머럴 리뷰 페르소나 — 리뷰 후 소멸 | X | X |

### 자기참조 패턴

에이전트에게 AGENT.md 경로만 전달하면, 에이전트가 스스로 읽고 부트스트랩합니다:
1. AGENT.md 읽기 (역할, 원칙)
2. config.json 확인 (라우팅, 모델)
3. harness/ 로드 (도메인 컨텍스트)
4. memory/context.md 참조 (축적된 학습)

## 아키타입 리뷰 시스템

34개 팬텀 아키타입을 팀으로 조합하여 다각도 리뷰 패널을 구성합니다.

### 카테고리

| 카테고리 | 수 | 설명 |
|----------|-----|------|
| dev | 11 | 전통적 개발 역할 (기획자, 디자이너, 프론트/백엔드, QA 등) |
| art | 9 | 예술적 관점 (화가, 작곡가, 조명감독 등) |
| persona | 8 | 사용자 페르소나 (연령대별, 접근성 등) |
| runtime-expert | 6 | AI/에이전트 전문가 |

### 리뷰 모드

| 모드 | 동작 |
|------|------|
| **parallel** | 전원 동시 실행 → 종합 |
| **round-robin** | 순차 실행, 이전 피드백 전달 |
| **debate** | 라운드별 토론 (최대 3라운드, consensus 기반) |

### 사용 예시

```bash
# 개발팀 전체 리뷰
aria-review --team dev-full --target "새 기능 PR"

# 크로스 체크 (토론 모드)
aria-review --team dev-cross --target "아키텍처 변경"

# 커스텀 조합
aria-review --members "frontend-dev,qa-engineer,security-expert" --target "로그인 페이지"
```

## 디렉토리 구조

```
~/.aria/
├── config.json                  # 글로벌 설정
├── bin/aria                     # CLI
├── agents/                      # Nyx 에이전트
│   ├── agents.json              #   레지스트리
│   └── {id}/                    #   에이전트별 디렉토리
│       ├── AGENT.md             #     역할, 원칙, 스킬
│       ├── config.json          #     유형, 모델, 라우팅
│       ├── memory/context.md    #     축적된 학습 (100줄)
│       └── harness/             #     도메인 컨텍스트
├── nyx/                         # Nyx 코어
│   ├── prompts/                 #   agent.md, spawn.md, phantom.md
│   ├── routing.json             #   키워드 → 에이전트 라우팅
│   └── README.md
├── khala/                       # 런타임 간 통신
│   ├── channels/                #   JSONL 메시지 채널
│   └── lib/khala-gc.sh          #   TTL 기반 정리
├── knowledge/                   # FTS5 지식 베이스
├── registry/                    # 런타임/노드 메타데이터
├── profiles/                    # 프로필 + 아키타입
│   ├── archetypes/              #   팬텀 리뷰 페르소나
│   └── teams/presets.json       #   팀 프리셋
├── skills/                      # 공유 스킬 라이브러리
└── runtimes/                    # 런타임별 어댑터
```

## 런타임 통합

| 런타임 | 유형 | 상태 | 통합 방식 |
|--------|------|------|-----------|
| OpenClaw | gateway | 활성 | Nyx 플러그인 (3도구 + CLI + hook) |
| Claude Code | cli | 활성 | CLAUDE.md + Agent tool |
| Codex | cli | 비활성 | 설정 준비됨 |
| Cursor | ide | 비활성 | 설정 준비됨 |

---

## 라이선스

MIT
