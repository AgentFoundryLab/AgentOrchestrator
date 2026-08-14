# AgentOrchestrator Data Model

**Version**: 0.1.0
**Date**: 2026-02-19
**Source**: decomposed from the retired `ARCHITECTURE.md`. Governing blueprint: [FBP-FND-001](FBP-FND-001.md).

---

## Overview

AgentOrchestrator is a configuration-driven system. Its "data model" is the set of file formats and memory structures that agents read, write, and query. There is no relational database in v0/v1 extended scope — all persistence is file-based or Serena MCP memory.

---

## Entity: Skill

**Location**: `package/skills/<name>/SKILL.md`
**Installed to**: `~/.claude/skills/jarvis/<name>/SKILL.md` (global) or `<project>/.claude/skills/jarvis/<name>/SKILL.md`

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| name | string | lowercase, hyphens only | Skill identifier used in frontmatter and `skills:` lists |
| description | string | required | Used by Claude for auto-invocation detection |
| argument-hint | string | optional | Shown in autocomplete |
| user-invocable | boolean | default: true | False hides from `/` menu |
| disable-model-invocation | boolean | default: false | True prevents model-triggered invocation |
| context | enum: fork | optional | Agent-backed skills only |
| agent | string | required if context=fork | Target agent subagent_type |
| allowed-tools | string[] | optional | Tool whitelist |
| instructions | markdown | required | Full skill workflow in markdown body |

**Relationships**:
- A Skill belongs to one Category (agent-backed, orchestration, utility, protocol)
- An agent-backed Skill targets one Agent via `agent:` field
- An Agent may have one or more Skills in its `skills:` list

---

## Entity: Agent

**Location**: `package/agents/<name>.md`
**Installed to**: `~/.claude/agents/jarvis/<name>.md` (global) or `<project>/.claude/agents/jarvis/<name>.md`

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| name | string | lowercase, hyphens | Agent identifier for Task tool `subagent_type` |
| description | string | required | When Claude should auto-delegate to this agent |
| tools | string[] | optional, inherits all | Tools the agent can use |
| disallowedTools | string[] | optional | Tools explicitly denied |
| model | enum | default: inherit | Model selection |
| permissionMode | enum | default: default | Permission level for destructive operations |
| skills | string[] | optional | Skill names whose content is injected at spawn |
| hooks.Stop | command[] | optional | Scripts to run when agent finishes |
| body | markdown | required | Agent persona, boundaries, reporting format |

**Relationships**:
- An Agent has one primary Skill (its main skill, included in `skills:` list)
- An Agent may have secondary Skills injected at user invocation
- An Agent produces one or more Artifact types

---

## Entity: Artifact

Abstract entity representing the output of a skill/agent invocation.

| Attribute | Type | Description |
|-----------|------|-------------|
| type | enum | FRD, TRD, FBP, ADR, ROADMAP, PLAN, WO, ISS, REG, TD, FB, CoverageDocument, ReviewReport, AnalysisReport, ResearchReport, STANDARDS, GUIDELINES, Code |
| location | path | Where the artifact is written |
| storage | enum: file, serena | File = git-versioned; Serena = transient memory |
| producer | Skill | Which skill created it |
| version | string | For versioned artifacts (STANDARDS, GUIDELINES) |

**Artifact Location Map**:

| Artifact Type | Location | Storage |
|---------------|----------|---------|
| FRD / TRD | `docs/requirements/{FRD,TRD}-<SCOPE>-NNN.md` | File |
| FBP | `docs/architecture/{foundation,feature}/FBP-<TIER>-NNN.md` | File |
| ADR | `docs/architecture/ADR/ADR-<TIER>-NNN.md` | File |
| ROADMAP / PLAN | `docs/development/ROADMAP.md`, `plans/PLAN-NNN-*.md` | File |
| WO | `docs/development/workorders/WO-NNN.md` | File |
| ISS / REG / TD | `docs/development/{issues,debt}/` | File |
| ISSUES | `docs/development/ISSUES.md` | File |
| STANDARDS | `docs/policy/STANDARDS.md` | File |
| GUIDELINES | `docs/policy/GUIDELINES.md` | File |
| ReviewReport | `docs/analysis/review-YYYY-MM-DD.md` | File |
| AnalysisReport | `docs/analysis/YYYY-MM-DD-topic.md` | File |
| ResearchReport | `reports/research/YYYY-MM-DD-topic.md` | File |
| CoverageDocument | `docs/validation/` | File |
| InstructionFixMemo | `reports/meta-optimization/YYYY-MM-DD-slug.md` | File |

---

## Entity: Policy File

Policy files are versioned configuration artifacts.

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| tier | enum: global, project | required | Global (framework) or project-specific |
| name | enum | required | PRINCIPLES, RULES (global); STANDARDS, GUIDELINES (project) |
| version | semver string | required for project | e.g., `1.0.0` |
| updated | date | required for project | YYYY-MM-DD |
| body | markdown | required | Policy content |

**Global Policy Entities** (in `<runtime-root>/policy/`):
- `PRINCIPLES.md` — Universal SW engineering philosophy
- `RULES.md` — Agent behavioral rules (orchestrator-level)

**Project Policy Entities** (in `<project>/docs/policy/`):
- `STANDARDS.md` — Project MUST conventions, generated by `/onboard`
- `GUIDELINES.md` — Project SHOULD practices, generated by `/onboard`

---

## Entity: Memory Record (Serena)

**Not implemented.** No skill issues `write_memory` or `read_memory`; `.serena/memories/` is created
empty and never filled. `ADR-FND-002` carries the tier model and its 2026-08-14 amendment recording
this; `WO-128`/`WO-129`/`WO-130` own building it.

The key patterns this section used to specify — `reflexion/<date>-<topic>` and
`reflection/<session_id>` — were named for `$reflexion` and `$reflect`, skills `$meta-learn`
absorbed. Specifying a schema for records nothing writes, under names nothing owns, is why this
entity is deferred to its implementing Work Orders rather than restated here.

What is durable today is the file entities above.

---

## Entity: Hook Event

Runtime events that trigger lifecycle scripts.

| Attribute | Type | Description |
|-----------|------|-------------|
| event | enum | SessionStart, SubagentStart, SubagentStop, Stop, SessionEnd |
| blocking | boolean | Whether Claude waits for script completion |
| stop_hook_active | boolean | SubagentStop phase (false=validation, true=learning) |
| script | path | Shell script that handles the event |
| output | string | Script stdout injected as system reminder |

---

## Entity: HITL Question Block

Structured output from sub-agents requiring user input.

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| questions | Question[] | 1-3 items | List of questions for user |
| question.text | string | required | Question text |
| question.required | boolean | required | True = blocking, False = optional |
| question.default | string | if optional | Default value if user skips |
| question.options | Option[] | optional | Enumerated choices |

---

## Relationships Summary

```
User
  └── invokes Skill (via /skill or orchestrate)
        └── forks into Agent (context: fork)
              └── injects Skills (via skills: list)
                    └── produces Artifacts
                          └── stored in File | Serena Memory

Agent
  ├── has primary Skill (1:1)
  ├── may receive secondary Skills (1:N via user invocation)
  └── fires Hook Events on Stop (0:N scripts)

Policy
  ├── Global tier: auto-loaded via @-refs in ~/.claude/CLAUDE.md
  └── Project tier: auto-loaded via @-refs in <project>/CLAUDE.md (if exists)
```
