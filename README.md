# ARIA — Agent-Runtime Integration Architecture

> **Documentation:** [English](README.md) | [한국어](docs/ko/README.ko.md)

## Screenshots

| | |
|---|---|
| ![aria status](docs/screenshots/aria-status.svg) | ![aria nyx list](docs/screenshots/aria-nyx-list.svg) |
| ![aria nyx archetypes](docs/screenshots/aria-nyx-archetypes.svg) | ![aria-review](docs/screenshots/aria-review-demo.svg) |

> Each runtime sings its own aria, together forming a single opera.

ARIA is a unified system for managing AI agents and their runtime environments. It brings together agent orchestration (**Nyx**), inter-runtime communication (**Khala**), a shared knowledge base, and a runtime/node registry under a single coherent structure.

## Quick Start

```bash
git clone https://github.com/songblaq/aria.git
cd aria
./install.sh
export PATH="$HOME/.aria/bin:$PATH"
aria status
```

### What you'll see

```
=== ARIA (Agent-Runtime Integration Architecture) v1.0.0 ===

  Config:     OK
  Knowledge:  484 chunks
  Khala:      27 channels, 16638 messages
  Runtimes:   2
  Nodes:      5
  Nyx Agents: 5
```

---

## Features at a Glance

### Nyx Agents — Persistent AI Workers

```
$ aria nyx list

=== Nyx Agents ===
  browser     harness  harness:Y mem:Y  browser — Web interaction agent
  director    harness  harness:Y mem:Y  director — AI media generation
  infra       harness  harness:Y mem:Y  infra — Infrastructure management
  nyx-ops     creator  harness:N mem:Y  nyx-ops — Agent meta-management
  openclaw    harness  harness:Y mem:Y  openclaw — Runtime operations

  Total: 5 agents
```

Each agent has: `AGENT.md` (role & principles), `config.json` (routing), `memory/context.md` (learning), `harness/` (domain context).

**Self-reference pattern:** Agents receive their own AGENT.md path and bootstrap themselves — reading their role, principles, and harness before executing any task.

### Review Archetypes — Multi-Perspective Panels

Assemble virtual review panels from 34 phantom archetypes across 4 categories:

```
$ aria nyx archetypes dev

=== Archetypes ===
  [dev]  backend-dev      Backend Developer
  [dev]  dba              DBA
  [dev]  designer         UI/UX Designer
  [dev]  devops           DevOps Engineer
  [dev]  frontend-dev     Frontend Developer
  [dev]  fullstack-dev    Fullstack Developer
  [dev]  planner          Product Planner
  [dev]  pm               Project Manager
  [dev]  project-lead     Technical Lead
  [dev]  qa-engineer      QA Engineer
  [dev]  security-expert  Security Expert

  Total: 11 archetypes
```

### Team Presets — Ready-Made Panels

```
$ aria nyx teams

=== Team Presets ===
  dev-full       Full Dev Team Review    [parallel]  planner, designer, frontend-dev, ...
  dev-cross      Cross-Check Team        [debate]    fullstack-dev, project-lead, pm, ...
  art-creative   Creative Audit          [round-robin] painter, composer, sculptor, ...
  holistic       Holistic Review         [debate]    fullstack-dev, composer, persona, professor
```

### Review Demo

```bash
# Assemble a cross-check team to review your code
$ aria-review --team dev-cross --target "Authentication module redesign"

{
  "team": "dev-cross",
  "mode": "debate",
  "reviewer_count": 4,
  "reviewers": [
    { "id": "fullstack-dev",  "name": "Fullstack Dev",  "category": "dev" },
    { "id": "project-lead",   "name": "Tech Lead",      "category": "dev" },
    { "id": "pm",             "name": "Project Manager", "category": "dev" },
    { "id": "security-expert","name": "Security Expert", "category": "dev" }
  ]
}
```

Each reviewer produces structured JSON findings with severity ratings. The orchestrator synthesizes results into a consensus report.

### Khala — Runtime Messaging

```
$ aria khala list

=== Khala Channels ===
  global/alerts          215 msgs
  global/heartbeats    16122 msgs
  global/knowledge         9 msgs
  global/tasks            72 msgs
  dev-team/inbox           0 msgs
  ...
```

### Knowledge Search

```bash
$ aria knowledge search "agent routing"    # Full-text search
$ aria knowledge store "New insight..."    # Store knowledge
$ aria knowledge stats                     # Database stats
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    ARIA v1.0.0                          │
│                                                         │
│  ┌─────────┐ ┌─────────┐ ┌──────────┐ ┌─────────────┐  │
│  │  Nyx    │ │ Khala   │ │Knowledge │ │  Registry   │  │
│  │ Agents  │ │Messaging│ │  FTS5    │ │  Discovery  │  │
│  └────┬────┘ └────┬────┘ └────┬─────┘ └──────┬──────┘  │
│       │           │           │              │          │
│  ┌────▼───────────▼───────────▼──────────────▼───────┐  │
│  │              Skills Library (169)                  │  │
│  └───────────────────────┬───────────────────────────┘  │
│                          │                              │
│  ┌───────────────────────▼───────────────────────────┐  │
│  │              Runtimes                             │  │
│  │  OpenClaw [ON]  Claude Code [ON]  Codex  Cursor   │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Components

| Component | Purpose | Backend |
|-----------|---------|---------|
| **Nyx** | Agent orchestration — routing, prompts, lifecycle | Keyword matching + fallback |
| **Khala** | Inter-runtime pub-sub messaging | ClawBus (JSONL channels) |
| **Knowledge** | Shared knowledge base | SQLite FTS5 |
| **Registry** | Runtime and node discovery | JSON files |

### Agent Types

| Type | Description | Persistent | Memory |
|------|-------------|------------|--------|
| **Harness** | Wraps external tools (SSH, ComfyUI, APIs) | Yes | Yes |
| **Pure** | LLM-prompt only, no external tooling | Yes | Yes |
| **Creator** | Can spawn and manage other agents | Yes | Yes |
| **Phantom** | Ephemeral review persona — destroyed after use | No | No |

### Review Modes

| Mode | How it works |
|------|-------------|
| **parallel** | All reviewers run simultaneously, synthesize after |
| **round-robin** | Sequential — each sees previous reviewers' findings |
| **debate** | Round 1 (parallel) → Round 2 (cross-respond) → Round 3 (if no consensus) |

---

## Directory Layout

```
~/.aria/                         # ARIA home
├── config.json                  # Global configuration
├── bin/aria                     # CLI entrypoint
├── agents/                      # Nyx agent definitions
│   ├── agents.json              #   Registry manifest
│   └── {id}/                    #   Per-agent directory
│       ├── AGENT.md             #     Role, principles, skills
│       ├── config.json          #     Type, model, routing keywords
│       ├── memory/context.md    #     Accumulated learning (100-line cap)
│       └── harness/             #     Domain context (optional)
├── nyx/                         # Nyx core
│   ├── prompts/                 #   agent.md, spawn.md, phantom.md
│   ├── routing.json             #   Keyword → agent routing rules
│   └── README.md                #   Nyx documentation
├── khala/                       # Inter-runtime messaging
│   ├── channels/                #   JSONL message channels
│   └── lib/khala-gc.sh          #   TTL-based message cleanup
├── knowledge/                   # FTS5 knowledge base
├── registry/                    # Runtime and node metadata
├── profiles/                    # Shared profiles + archetypes
│   ├── archetypes/{category}/   #   Phantom review personas
│   └── teams/presets.json       #   Team composition presets
├── skills/                      # Shared skill library
└── runtimes/                    # Per-runtime adapters + skills
    ├── openclaw/
    ├── claude-code/
    ├── codex/
    └── cursor/
```

---

## CLI Reference

```bash
# System
aria status                             # Health check
aria version                            # Version info

# Nyx — Agents
aria nyx list                           # List all agents
aria nyx info <id>                      # Agent details (config, memory, harness)
aria nyx archetypes [category]          # List review archetypes
aria nyx teams                          # List team presets

# Khala — Messaging
aria khala list                         # List all channels with message counts
aria khala publish <channel> <message>  # Publish to a channel
aria khala tail <channel> [n]           # Show recent messages

# Knowledge
aria knowledge search <query> [limit]   # Full-text search
aria knowledge store <text>             # Store new knowledge
aria knowledge stats                    # Database statistics

# Registry
aria registry runtimes                  # List registered runtimes
aria registry nodes                     # List registered nodes
```

---

## Runtime Integration

| Runtime | Type | Status | Integration |
|---------|------|--------|-------------|
| **OpenClaw** | gateway | Active | Nyx plugin (3 tools + CLI + prompt hook) |
| **Claude Code** | cli | Active | CLAUDE.md section + Agent tool |
| **Codex** | cli | Planned | Config ready |
| **Cursor** | ide | Planned | Config ready |

---

## Examples

The `examples/` directory contains public-safe templates:

```
examples/
├── archetypes/dev/       # 11 development role archetypes
├── teams/                # Team preset examples
├── nyx-prompts/          # Prompt templates (agent, spawn, phantom)
├── config.example.json   # Configuration template
└── routing.example.json  # Routing rules template
```

---

## Contributing

Contributions welcome. Please open an issue first to discuss proposed changes.

## License

MIT
