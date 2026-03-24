# AgentHive Task Protocol Skill

## Purpose
AgentHive 태스크 라이프사이클을 올바르게 따르도록 가이드하는 스킬.

## Task Lifecycle
```
backlog → ready → doing → review → done
                    ↓
                  blocked
```

## Core Principles
1. One Task, One Owner, One Scope
2. Plan Before Modify
3. Review After Modify
4. Append-Only

## Task Directory Structure
```
tasks/TASK-NNN-slug/
  task.yaml
  plan.md
  summary.md
  lock.yaml
  messages/
  reviews/
  artifacts/
```
