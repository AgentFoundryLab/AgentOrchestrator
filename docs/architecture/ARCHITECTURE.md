# AgentOrchestrator Architecture Specification

**Version**: 0.2.0
**Status**: Draft
**Date**: 2026-02-24
**Source**: [PRD.md](PRD.md)

---

## Executive Summary

This document defines the technical architecture for AgentOrchestrator, a minimalist multi-agent orchestration framework for Claude Code. The architecture follows the Orchestrator blueprint with a lean subset focused on skills, agents, workflows, and memory.

**Key Architectural Decisions**:
- Pure markdown/JSON configuration (zero Python dependencies)
- Flat package source transformed into runtime-native layouts across Claude/Codex/Gemini/OpenCode/Qwen (see ADR-014)
- Required Serena MCP plus recommended Context7/DeepWiki/Parallel Search/Task and optional Playwright (see ADR-003)
- Hook-based lifecycle management (reminder pattern, not enforcement)
- Four-tier memory system (Session, Semantic, Reflexion, Transient)
- Two-tier policy structure (global framework + project-specific)
- HITL escalation via structured QUESTIONS block (not direct `AskUserQuestion`)

---

## System Overview

> **See**: [System Diagrams](diagrams/system-overview.md)

### What Orchestrator Provides vs Claude Code Native

| Component | Provider | Description |
|-----------|----------|-------------|
| Skill routing (`/skill` → SKILL.md) | **Claude Code** | Native skill dispatch |
| Task tool (subagent spawning) | **Claude Code** | Native agent invocation |
| Hook execution | **Claude Code** | Native lifecycle events |
| Skill definitions (SKILL.md files) | **Orchestrator** | Instructions for each skill |
| Agent definitions (.md files) | **Orchestrator** | Thin wrappers with skills injected |
| Hook scripts (.sh files) | **Orchestrator** | Reminder scripts for validation/learning |
| Workflows (templates) | **Orchestrator** | Agent orchestration patterns |
| Policy (principles, rules) | **Orchestrator** | Behavioral guidelines |
| HITL shared protocol | **Orchestrator** | Standardized escalation pattern |

---

## Component Specifications

### 1. Skill System

Skills are the primary user interface. Skill definitions use `SKILL.md` with YAML frontmatter and are installed to runtime-native targets. Claude Code natively routes `/skill` invocations to the corresponding skill definition.

#### 1.1 Skill Categories

| Category | Skills | Invocation Pattern | Context |
|----------|--------|-------------------|---------|
| **Agent-backed** | spec, design, plan, implement, validate, deploy, document, onboard, review | `context: fork` + `agent:` injects skill into specified agent | fork |
| **Orchestration** | orchestrate | Calls agents via Task tool; agents have skills loaded via `skills:` | inline |
| **Utility** | reflexion, reflect, optimize, analyse, research, distill | Runs inline, no agent delegation | inline |
| **Shared Protocol** | hitl | Non-invocable protocol definition; injected into agent context via `skills:` | — |

> **Key Design**: Agent-backed skills use `context: fork` to inject content into the specified agent. Both direct invocation (`/spec`) and orchestrated invocation (agent's `skills:` list) result in skill content being injected into agent context. Single source of truth, no duplication.

> **HITL Skill**: `/hitl` has `user-invocable: false` and `disable-model-invocation: true`. It defines the escalation protocol and is referenced (not invoked) by agents.

#### 1.2 Skill Interface Contract

```yaml
---
name: skill-name                    # Required: lowercase + hyphens
description: What this skill does   # Required: for auto-invocation
argument-hint: [target] [options]   # Optional: autocomplete hint
disable-model-invocation: false     # Optional: true = user-only
user-invocable: true                # Optional: false = hide from menu
allowed-tools: Read, Grep, Bash     # Optional: tool whitelist
model: sonnet                       # Optional: model override
context: fork                       # Agent-backed skills: fork to inject into agent
agent: business-analyst             # Agent-backed skills: target agent for injection
---

# Skill Instructions

## Purpose
[What this skill accomplishes]

## Inputs
- `$ARGUMENTS`: User-provided arguments
- `${PROJECT_NAME}`: Derived from working directory
- `${CLAUDE_SESSION_ID}`: Current session identifier

## Outputs
[Artifact type and storage location]

## Workflow
[Step-by-step execution]
```

#### 1.3 Full Skill Inventory

| Skill | Agent | Category | Output | User-Invocable |
|-------|-------|----------|--------|----------------|
| `/spec` | Business Analyst | Agent-backed | PRD | Yes |
| `/design` | Architect | Agent-backed | Architecture doc, ADR | Yes |
| `/plan` | Project Manager | Agent-backed | ROADMAP, BACKLOG | Yes |
| `/implement` | Developer | Agent-backed | Code, tests | Yes |
| `/validate` | Validator | Agent-backed | Validation report | Yes |
| `/deploy` | Deployer | Agent-backed | Deployment artifacts | Yes |
| `/document` | Tech Writer | Agent-backed | Docs, README | Yes |
| `/onboard` | Architect | Agent-backed | STANDARDS.md, GUIDELINES.md | Yes |
| `/review` | Tech Writer | Agent-backed | Review report, ISSUES.md | Yes |
| `/orchestrate` | — | Orchestration | Workflow execution | Yes |
| `/reflexion` | — | Utility | Serena reflexion record | Yes |
| `/reflect` | — | Utility | Serena reflection record | Yes |
| `/optimize` | — | Utility | Meta-Opt Plan | Yes |
| `/analyse` | — | Utility | Analysis report | Yes |
| `/research` | — | Utility | Research summary | Yes |
| `/distill` | — | Utility | Distilled content | Yes |
| `/hitl` | — | Shared Protocol | — | No |

**Total: 17 skills** (16 user-invocable + 1 protocol)

#### 1.4 Skill-Agent Relationship

There are **two invocation paths** for agent-backed skills. Both use **content injection**.

> **See**: [Invocation Paths Diagram](diagrams/invocation-paths.md)

**Both paths use injection** (from Claude Code docs):
> "The full content of each skill is injected into the subagent's context, not just made available for invocation."

**Benefits of this design:**
- **No duplication**: Skill is single source of truth
- **Both paths spawn agent**: Hooks fire in both cases
- **Two injection mechanisms**: `context: fork` (direct) and `skills:` (orchestrated)
- **Consistent behavior**: Same agent, same hooks, same outcome

#### 1.5 HITL Shared Protocol

The `/hitl` skill is a non-invocable protocol definition. It enforces a single source of truth for human-in-the-loop escalation:

- Sub-agents spawned via Task tool CANNOT call `AskUserQuestion` directly
- When blocked, agents emit a structured `## QUESTIONS FOR USER` block
- Orchestrator detects the block, relays via `AskUserQuestion`, re-invokes agent with answers
- Protocol details: `/hitl` shared protocol definition and HITL decision record
- Decision record: `docs/knowledge/decisions/hitl-escalation.md`

> **See**: [ADR-012](adr/012-governance-rationalization.md) and [HITL Decision](../../docs/knowledge/decisions/hitl-escalation.md)

#### 1.6 Conflict Detection in /document Skill

The `/document` skill includes conflict detection to prevent silent overwrites:

**Conflict Types Detected:**
| Type | Example | Severity |
|------|---------|----------|
| **Decision Conflict** | New code contradicts ADR decision | HIGH |
| **Specification Drift** | Implementation differs from PRD | HIGH |
| **Cross-Doc Mismatch** | ARCHITECTURE says X, README says Y | MEDIUM |
| **Stale Reference** | Doc references removed component | MEDIUM |
| **Version Mismatch** | Changelog vs actual version | LOW |

**Conflict Resolution Flow:**
1. Detect inconsistency during documentation update
2. Present conflict to user via `AskUserQuestion`
3. User chooses: update old, keep old, document tentatively, or pause
4. If tentative/rejected: log to ISSUES.md with suggested agent for resolution

---

### 2. Agent System

Agents are specialized workers invoked via Claude Code's Task tool with `subagent_type` parameter.

#### 2.1 Agent Architecture

> **See**: [Agent-Skill Injection Diagram](diagrams/agent-skill-injection.md)

#### 2.2 Agent Specifications

| Agent | Responsibility | Tools | Disallowed | Permission Mode | Artifacts |
|-------|---------------|-------|------------|-----------------|-----------|
| **Business Analyst** | Requirements elicitation, acceptance criteria | Read, Grep, Glob, WebSearch | - | default | PRD, User Stories |
| **Architect** | System design, constraints, trade-offs, onboarding | Read, Grep, Glob, WebSearch | - | default | Architecture doc, ADR, STANDARDS.md, GUIDELINES.md |
| **Project Manager** | Planning, sequencing, decomposition | Read, Write, TaskCreate | - | default | ROADMAP, BACKLOG |
| **Developer** | Implementation, code changes | Read, Write, Edit, Bash, Task | - | default | Code, tests |
| **Validator** | Testing, acceptance criteria checking | Read, Grep, Glob, Bash | Write, Edit | default | Validation report |
| **Deployer** | Build, deploy, release | Read, Write, Bash | Edit | **plan** | Deployment artifacts |
| **Tech Writer** | Documentation, runbooks, cross-artifact review | Read, Write, Grep, Glob, AskUserQuestion | Edit | default | Docs, README, Review report |

#### 2.3 Agent with Skill Injection

Agents load skill content via `skills:` frontmatter. The skill instructions are **injected** into the agent's context.

```markdown
# Example: agent definition
---
name: business-analyst
description: Requirements elicitation and PRD generation
skills:
  - spec                              # Skill content injected for orchestrated path
hooks:
  Stop:
    - hooks:
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-validate.sh"
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-reflexion.sh"
---

You are a Business Analyst responsible for requirements elicitation
and PRD generation.

## Boundaries
- **Will**: Generate PRDs, define acceptance criteria, ask clarifying questions
- **Won't**: Write code, make architectural decisions
```

> **Note**: Agent frontmatter hooks use `Stop` (fires when agent finishes). Settings-level hooks can use `SubagentStop` (fires when any subagent completes from parent's perspective).

#### 2.4 Multi-Skill Model (Primary + Adhoc)

Agents can receive skills through two mechanisms - both triggered by the **USER**, not by agents themselves.

> **See**: [Agent-Skill Mapping Diagram](diagrams/agent-skill-mapping.md) and [ADR-004](adr/004-skill-agent-invocation-paths.md)

**Invocation Scenarios:**

| User Action | Agent Spawned | Skills Injected |
|-------------|---------------|-----------------|
| `/design "auth system"` | Architect | /design (via `context: fork`) |
| `/onboard` | Architect | /design (primary) + /onboard (secondary) |
| `/review` | Tech Writer | /document (primary) + /review (secondary) |
| Orchestrator calls Task(architect) | Architect | /design (via `skills:` list) |
| `/analyse "auth patterns"` | Architect | /design (primary) + /analyse (secondary) |

#### 2.5 Agent Communication Pattern

> **See**: [Orchestrated Workflow Diagram](diagrams/orchestrated-workflow.md)

---

### 3. Workflow Engine

The workflow engine coordinates agents through defined templates.

#### 3.1 Workflow Templates

> **See**: [Workflow Engine Diagram](diagrams/workflow-engine.md)

**Workflow 1: Idea to Implementation** — Three depth levels (Full, Medium, Light) based on complexity assessment. Full workflow now includes `/review` gate:

```
Full:   /spec → /design → /plan → /review → /implement → /validate → /deploy → /document
Medium: /spec → /plan → /implement → /validate
Light:  /plan → /implement
```

**Workflow 2: Session to Meta-Learning** — Session → /reflect → /optimize → Approval → Rollout cycle.

**Workflow 3: Project Onboarding** — `/onboard` → STANDARDS.md + GUIDELINES.md (brownfield bootstrap).

#### 3.2 Workflow Depth Selection

```python
# Pseudocode for workflow depth selection
def select_workflow_depth(request):
    complexity = assess_complexity(request)

    if complexity == "high" or is_new_product(request):
        return "full"  # spec -> design -> plan -> review -> implement -> validate -> deploy -> document
    elif complexity == "medium" or is_feature(request):
        return "medium"  # spec -> plan -> implement -> validate
    else:  # simple change
        return "light"  # plan -> implement

def assess_complexity(request):
    factors = {
        "new_system": 3,
        "multiple_components": 2,
        "integration_needed": 2,
        "new_api": 1,
        "ui_changes": 1,
        "simple_fix": -2,
        "documentation_only": -3
    }
    score = sum(factors.get(f, 0) for f in detect_factors(request))

    if score >= 4:
        return "high"
    elif score >= 1:
        return "medium"
    else:
        return "low"
```

---

### 4. Hook System

Hooks provide lifecycle event handling through reminder scripts.

#### 4.1 Hook Architecture

> **See**: [Hook System Diagram](diagrams/hook-system.md) and [ADR-001](adr/001-hook-reminder-pattern.md)

**Important**: Stop ≠ SessionEnd
- **Stop**: Fires when Claude finishes responding. CAN block. CAN invoke skills.
- **SessionEnd**: Fires when session actually closes. CANNOT block. Cleanup only.

#### 4.2 Hook Specifications

| Hook Event | Trigger | Blocking | Script | Purpose |
|------------|---------|----------|--------|---------|
| **SessionStart** | Session begins | No | `inject-context.sh` | Inject `PROJECT_NAME`, `SESSION_ID` |
| **Stop** (agent) | Agent finishes | **Yes** | `remind-validate.sh` | Agent self-validation |
| **Stop** (agent) | Agent finishes | **Yes** | `remind-reflexion.sh` | Agent invokes `/reflexion` if errors |
| **Stop** (main) | Claude finishes responding | **Yes** | `remind-reflect.sh` | Orchestrator checklist, invoke `/reflect` |
| **SessionEnd** | Session closes | No | `checkpoint-session.sh` | Cleanup, logging, checkpoint state |

> **Note**: Agent frontmatter only supports `PreToolUse`, `PostToolUse`, and `Stop` hooks. Settings-level hooks support additional events like `SubagentStop`, `UserPromptSubmit`, etc.

#### 4.2.1 Hook Script Paths

Hook scripts are located in `package/hooks/scripts/` (source) and deployed to `.claude/hooks/scripts/` (project) or `~/.claude/hooks/scripts/` (global):

```json
// In settings.json (global hooks) - uses $HOME for global path
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/inject-context.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/scripts/remind-reflect.sh"
          }
        ]
      }
    ]
  }
}
```

```yaml
# In agent frontmatter - uses $CLAUDE_PROJECT_DIR for project path
hooks:
  Stop:
    - hooks:
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-validate.sh"
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-reflexion.sh"
```

#### 4.3 Hook Script Interface

```bash
#!/bin/bash
# remind-validate.sh
# Output is injected as system reminder to agent

cat << 'EOF'
<system-reminder>
SELF-VALIDATION CHECKLIST:
Before completing, verify:
1. [ ] All acceptance criteria from requirements are met
2. [ ] Artifact schema is valid
3. [ ] No assumptions without evidence
4. [ ] Tests pass (if applicable)

If any item fails, address before completing.
</system-reminder>
EOF
```

#### 4.4 Python Script Conventions

**All Python scripts must be self-contained via uvx shebang** for zero-dependency execution:

```python
#!/usr/bin/env -S uvx --from package-name python
```

**Execution**: Always run directly (`./script.py`), never with Python interpreter (`python script.py`).

#### 4.5 Hook Log Structure

Hook scripts log session and agent lifecycle events for observability and debugging.

**Directory Structure:**
```
logs/sessions/<session_id>/
├── session-start.jsonl      # Session start events (JSONL for resume support)
├── session-end.jsonl        # Session end events (JSONL for resume support)
├── events.log               # Human-readable event timeline
└── <agent_id>/              # Per-agent subdirectory
    ├── agent-start.json     # Agent spawn metadata (single JSON)
    └── agent-stop.jsonl     # Agent stop events (JSONL for two-phase flow)
```

**Two-Phase SubagentStop Flow:**

The SubagentStop hook fires twice per agent completion, controlled by `stop_hook_active`:

| Phase | `stop_hook_active` | Script | Action |
|-------|-------------------|--------|--------|
| 1 (Validation) | `false` | `remind-validate.sh` | Self-validation checklist |
| 2 (Reflexion) | `true` | `remind-reflexion.sh` | Reflexion prompt if errors |

---

### 5. Memory System

Four-tier memory architecture for different persistence needs.

#### 5.1 Memory Architecture

> **See**: [Memory System Diagram](diagrams/memory-system.md) and [ADR-002](adr/002-four-tier-memory.md)

#### 5.2 Memory Access Patterns

**Agent Initialization Memory Loading**:

| Memory Type | Load Pattern | Content |
|-------------|--------------|---------|
| **Semantic (knowledge/)** | Auto-load at spawn | Project architecture, API patterns, domain model, conventions |
| **Reflexion (reflexion/)** | Query on error/issue | Known issues, root causes, solutions, prevention strategies |
| **Transient** | Not loaded | Ephemeral validation/reflection records |

#### 5.3 Reflexion Memory Schema

```yaml
# reflexion/2026-01-23-auth-error.md
---
date: 2026-01-23
agent: Developer
task: Implement OAuth flow
severity: high
---

## Known Issue
Authentication fails silently when refresh token expires

## Root Cause
Token refresh endpoint returns 401 but error handler swallows exception

## Solution
1. Added explicit error handling for 401 response
2. Implemented token refresh retry logic
3. Added user notification for re-authentication

## Prevention
- Always handle 401 responses explicitly in auth flows
- Add logging for token lifecycle events
```

---

### 6. Policy System

Two-tier policy structure separates framework-level rules from project-specific standards.

#### 6.1 Policy Tiers

> **See**: [ADR-006](adr/006-policy-modularization.md) and [ADR-012](adr/012-governance-rationalization.md)

**Tier 1: Global Framework Policy** (auto-loaded via `~/.claude/CLAUDE.md` `@`-references)

| File | Tokens | Purpose | Scope |
|------|--------|---------|-------|
| `~/.claude/policy/PRINCIPLES.md` | ~640 | Universal SW engineering philosophy | All agents, always |
| `~/.claude/policy/RULES.md` | ~4,200 | Agent behavioral rules | Orchestrator-level |

**Tier 2: Project-Specific Policy** (auto-loaded via project `CLAUDE.md` `@`-references)

| File | Purpose | Generated By |
|------|---------|--------------|
| `docs/policy/STANDARDS.md` | MUST-level: stack, naming, patterns, test requirements | `/onboard` or manual |
| `docs/policy/GUIDELINES.md` | SHOULD-level: workflow, review process, deployment | `/onboard` or manual |

**Policy Sources (package)**:

| Source | Installed To |
|--------|-------------|
| `package/policy/PRINCIPLES.md` | `~/.claude/policy/PRINCIPLES.md` |
| `package/policy/RULES.md` | `~/.claude/policy/RULES.md` |
| `package/templates/standards.md` | Template used by `/onboard` to create `docs/policy/STANDARDS.md` |
| `package/templates/guidelines.md` | Template used by `/onboard` to create `docs/policy/GUIDELINES.md` |

**Key distinction from v0**:
- v0 had `docs/policy/RULES.md` (duplicate of global, never loaded) — deleted in ADR-012
- v1 has `docs/policy/STANDARDS.md` (project-specific, distinct naming from global)

#### 6.2 Policy Loading Flow

```
~/.claude/CLAUDE.md
  @~/.claude/policy/PRINCIPLES.md     ← always in context
  @~/.claude/policy/RULES.md          ← always in context (orchestrator)

<project>/CLAUDE.md
  @docs/policy/STANDARDS.md           ← project MUST conventions (if exists)
  @docs/policy/GUIDELINES.md          ← project SHOULD practices (if exists)
```

Sub-agents receive PRINCIPLES + STANDARDS/GUIDELINES via `@`-refs. RULES is orchestrator-level only.

---

### 7. Knowledge Base

Project-specific knowledge lives in `docs/knowledge/` and is loaded into agent context via Serena memory at spawn.

#### 7.1 Knowledge Structure

Knowledge structure layout examples are maintained in `docs/knowledge/README.md`.

#### 7.2 Knowledge Ontology

The knowledge system is modeled as typed entities with explicit relationships and governance rules.

| Entity Type | Layer | Purpose | Canonical Location |
|-------------|-------|---------|--------------------|
| **Requirement** (`FR`/`NFR`/`US`) | Specification | Defines expected behavior and constraints | `docs/architecture/PRD.md` |
| **Architecture Decision Record (ADR)** | Specification | Captures significant architecture decisions and trade-offs | `docs/architecture/adr/` |
| **Technical Decision Record (TDR)** | Knowledge | Captures non-architectural technical/operational decisions | `docs/knowledge/decisions/` |
| **Pattern/Convention** | Knowledge | Reusable implementation/documentation patterns | `docs/knowledge/patterns/` (or equivalent) |
| **Runbook/Procedure** | Knowledge | Operational procedures and recovery workflows | `docs/knowledge/runbooks/` (or equivalent) |
| **Issue/Gap** | Execution | Tracks defects, blockers, drift, debt | `docs/development/ISSUES.md` |
| **Task** | Execution | Atomic implementation/validation work unit | `docs/development/BACKLOG.md` |
| **Validation Evidence** | Execution | Proof that behavior/constraints are satisfied | `reports/validation/`, `reports/analysis/` |

**Allowed Relationship Model**

| Source | Relationship | Target | Rule |
|--------|--------------|--------|------|
| Requirement | `constrains` | ADR, TDR, Pattern, Task | Downstream artifacts must trace to requirements. |
| ADR | `governs` | Architecture sections, contracts, component boundaries | ADR is authoritative for architecture-level decisions. |
| TDR | `guides` | Runbooks, process conventions, operational behavior | TDR must not redefine architecture decisions. |
| Issue | `triggers` | Task, TDR review, ADR review | Issues can trigger review/escalation; they do not redefine architecture by themselves. |
| Validation Evidence | `verifies` | Requirement, ADR assumption, Task completion | Evidence confirms or refutes implemented behavior. |
| Task | `implements` | Requirement and design intent | Tasks are execution-level realization of upstream artifacts. |

**Lifecycle Semantics**

- ADR lifecycle: `Proposed` -> `Accepted` -> (`Deprecated` | `Superseded`)
- TDR lifecycle: `Draft` -> `Active` -> (`Archived` | `Superseded`)
- Knowledge entries should include: date, owner, rationale, and links to upstream requirement/decision context.

**Governance Constraints**

- ADR and TDR are distinct artifact classes and must not be mixed.
- Architecture (`ARCHITECTURE.md`, ADRs) is upstream of execution artifacts (`BACKLOG`, `ISSUES`).
- Execution artifacts may reference architecture for traceability; architecture must not use execution artifacts as normative design input.

---

### 8. MCP Integration

Minimal MCP footprint with one required server, recommended support servers, and optional add-ons.

#### 8.1 MCP Architecture

> **See**: [ADR-003 - Minimal MCP Footprint](adr/003-minimal-mcp-footprint.md)

| Server | Status | Purpose |
|--------|--------|---------|
| **Serena** | Required | Session persistence, semantic memory, symbolic code operations |
| **Context7** | Recommended | Documentation lookup, hallucination prevention |
| **DeepWiki** | Recommended | GitHub repository documentation |
| **Parallel Search** | Recommended | Fast parallel web lookups for research workflows |
| **Parallel Task** | Recommended | Deep research and batch enrichment task execution |
| **Playwright** | Optional | Browser automation for validation |

#### 8.2 MCP Usage Patterns

| Use Case | MCP Server | Tool | Skill |
|----------|------------|------|-------|
| Store reflexion | Serena | write_memory | /reflexion |
| Query past errors | Serena | read_memory | Agent init |
| Code navigation | Serena | find_symbol | /analyse |
| Look up docs | Context7 | query-docs | /research, /design |
| Look up repo | DeepWiki | query | /research, /design |
| Parallel web search | Parallel Search | web_search_preview / web_fetch | /research, /design |
| Deep research runs | Parallel Task | createDeepResearch / createTaskGroup | /research |
| Visual validation | Playwright | screenshot | /validate |

---

### 9. File Structure

Detailed file organization for Orchestrator installation.

#### 9.1 Repository Structure

```
orchestrator/
├── README.md                           # Project overview
├── install.sh                          # Installer script
├── AGENTS.md                           # Agent coordination document (loaded by Claude)
├── CLAUDE.md                           # Claude project instructions (loads AGENTS.md)
│
├── docs/                               # Orchestrator's own docs (dogfooding)
│   ├── objectives/
│   │   ├── VISION.md
│   │   ├── BLUEPRINT.md                # Technical scope, capabilities
│   │   └── ROADMAP.md
│   ├── architecture/
│   │   ├── PRD.md
│   │   ├── ARCHITECTURE.md             # This document
│   │   ├── DESIGN-PRINCIPLES.md        # Orchestrator-specific design principles
│   │   ├── adr/
│   │   │   ├── 001-hook-reminder-pattern.md
│   │   │   ├── 002-four-tier-memory.md
│   │   │   ├── 003-minimal-mcp-footprint.md
│   │   │   ├── 004-skill-agent-invocation-paths.md
│   │   │   ├── 005-task-decomposition-hierarchy.md
│   │   │   ├── 006-policy-modularization.md
│   │   │   ├── 007-multi-agent-protocol-selection.md
│   │   │   ├── 008-multi-provider-integration-strategy.md
│   │   │   ├── 009-orchestration-framework-selection.md
│   │   │   ├── 010-observability-architecture.md
│   │   │   ├── 011-coordination-level-strategy.md
│   │   │   ├── 012-governance-rationalization.md
│   │   │   ├── 013-extended-skills.md
│   │   │   └── 014-multi-agent-installer.md
│   │   └── diagrams/
│   ├── development/
│   │   ├── BACKLOG.md
│   │   └── ISSUES.md
│   ├── policy/
│   │   ├── README.md                   # Policy index (no RULES.md — deleted by ADR-012)
│   │   ├── STANDARDS.md                # Orchestrator-specific technical standards
│   │   └── GUIDELINES.md              # Orchestrator process guidelines
│   └── knowledge/
│       ├── README.md                   # Knowledge base index
│       └── decisions/                  # Lightweight decision records
│           └── hitl-escalation.md
│
├── package/                            # Source layout (deployed into runtime-native structures)
│   ├── settings.json                   # Global settings template
│   ├── mcp.json                        # Global MCP servers template
│   │
│   ├── agents/                         # → Runtime-native agents path (see §9.2)
│   │   ├── business-analyst.md
│   │   ├── architect.md
│   │   ├── project-manager.md
│   │   ├── developer.md
│   │   ├── validator.md
│   │   ├── deployer.md
│   │   └── tech-writer.md
│   │
│   ├── skills/                         # → Runtime-native skills path (see §9.2)
│   │   ├── orchestrate/SKILL.md
│   │   ├── spec/SKILL.md
│   │   ├── design/SKILL.md
│   │   ├── plan/SKILL.md
│   │   ├── implement/SKILL.md
│   │   ├── validate/SKILL.md
│   │   ├── deploy/SKILL.md
│   │   ├── document/SKILL.md
│   │   ├── onboard/SKILL.md
│   │   ├── review/SKILL.md
│   │   ├── hitl/SKILL.md
│   │   ├── reflexion/SKILL.md
│   │   ├── reflect/SKILL.md
│   │   ├── optimize/SKILL.md
│   │   ├── analyse/SKILL.md
│   │   ├── research/SKILL.md
│   │   └── distill/SKILL.md
│   │
│   ├── hooks/                          # → .claude/hooks/ (project) or ~/.claude/hooks/ (global)
│   │   ├── README.md
│   │   └── scripts/
│   │       ├── lib/hook-utils.sh
│   │       ├── inject-context.sh
│   │       ├── remind-validate.sh
│   │       ├── remind-reflexion.sh
│   │       ├── remind-reflect.sh
│   │       ├── checkpoint-session.sh
│   │       └── setup-project.sh
│   │
│   ├── policy/                         # → ~/.claude/policy/
│   │   ├── RULES.md
│   │   └── PRINCIPLES.md
│   │
│   ├── workflows/                      # → ~/.claude/workflows/
│   │   ├── SWE.md
│   │   └── meta-learning.md
│   │
│   ├── templates/                      # → ~/.claude/templates/ (and project-local)
│       ├── vision.md
│       ├── blueprint.md
│       ├── prd.md
│       ├── architecture.md
│       ├── adr.md
│       ├── roadmap.md
│       ├── backlog.md
│       ├── issues.md
│       ├── standards.md
│       ├── guidelines.md
│       └── knowledge.md
│
│   └── install/
│       └── runtimes.sh                 # Canonical runtime registry (ADR-014 D-4)
│
└── .serena/                            # Serena MCP local storage
    └── README.md
```

#### 9.2 Installation Targets

Installer writes runtime-native artifacts for each supported runtime. Canonical capability and namespace behavior is defined in [ADR-014](adr/014-multi-agent-installer.md).

**Namespace support (ADR-014 D-2)**:
- Flat mode is the default installation mode.
- Optional namespace input is translated per runtime/artifact semantics.
- Runtime-owned namespace forms are preserved rather than normalized into a synthetic universal format.

#### 9.3 Installation Behavior

The `install.sh` script handles existing files intelligently:

| File Type | Behavior | Rationale |
|-----------|----------|-----------|
| `*.json` (settings, mcp) | **Patch/merge** | Preserve user customizations, add Orchestrator keys |
| `*.md` (agents, skills) | **Warn if different** | Don't overwrite user modifications |
| `*.sh` (hooks) | **Backup + overwrite** | Scripts should match Orchestrator version |
| New files | **Create** | No conflict |

---

### 10. Artifact Storage

Where skills write their outputs.

#### 10.1 Artifact Locations

```
target-project/
├── docs/
│   ├── objectives/                  # Strategic layer
│   │   ├── VISION.md                # User-managed (why, who)
│   │   ├── BLUEPRINT.md             # User-managed (scope, capabilities)
│   │   └── ROADMAP.md               # /plan updates (milestones, phases)
│   │
│   ├── architecture/                # Specification layer
│   │   ├── PRD.md                   # /spec output
│   │   ├── ARCHITECTURE.md          # /design output
│   │   └── adr/                     # /design ADR output
│   │       └── 001-decision.md
│   │
│   ├── development/                 # Execution layer
│   │   ├── BACKLOG.md               # Prioritized tasks
│   │   └── ISSUES.md                # Discovered bugs/blockers + /review blocking items
│   │
│   ├── policy/                      # Project governance
│   │   ├── STANDARDS.md             # /onboard output (MUST conventions)
│   │   └── GUIDELINES.md            # /onboard output (SHOULD practices)
│   │
│   └── knowledge/                   # Project knowledge base
│       ├── README.md                # Knowledge index
│       └── decisions/               # Lightweight decision records
│
├── reports/                         # Git-versioned skill outputs
│   ├── analysis/                    # /analyse and /review output
│   │   ├── 2026-01-23-auth-issue.md
│   │   └── review-2026-02-19.md     # /review cross-artifact report
│   └── research/                    # /research output
│       └── 2026-01-23-oauth-providers.md
│
├── src/                             # /implement output
│   └── ...
│
└── .serena/                         # Transient artifacts (Serena memories)
    # /validate → validation records
    # /reflect → reflection records
    # /reflexion → reflexion records
```

---

## Design Decisions

Full Architecture Decision Records are maintained in the [adr/](adr/) directory:

| ADR | Title | Summary |
|-----|-------|---------|
| [ADR-001](adr/001-hook-reminder-pattern.md) | Hook Behavior Pattern | Blocking hooks (SubagentStop, Stop) for reminders; SessionEnd for cleanup |
| [ADR-002](adr/002-four-tier-memory.md) | Four-Tier Memory | Session, Semantic, Reflexion, Transient tiers with different lifecycles |
| [ADR-003](adr/003-minimal-mcp-footprint.md) | Minimal MCP Footprint | Serena required; Context7/DeepWiki/Parallel Search/Task recommended; Playwright optional |
| [ADR-004](adr/004-skill-agent-invocation-paths.md) | Skill-Agent Invocation | Skill-driven injection via `context: fork` + agent's `skills:` list |
| [ADR-005](adr/005-task-decomposition-hierarchy.md) | Task Decomposition | Milestone → Phase → Epic → Task hierarchy for agent workflows |
| [ADR-006](adr/006-policy-modularization.md) | Policy Modularization | Reference-based policy loading with two-tier structure |
| [ADR-007](adr/007-multi-agent-protocol-selection.md) | Multi-Agent Protocol | A2A + MCP protocol selection for v1 |
| [ADR-008](adr/008-multi-provider-integration-strategy.md) | Multi-Provider Integration | Strategy for Gemini/Codex alongside Claude |
| [ADR-009](adr/009-orchestration-framework-selection.md) | Orchestration Framework | Strands Framework selection for v1 |
| [ADR-010](adr/010-observability-architecture.md) | Observability Architecture | OTEL + Prometheus + Loki + Grafana for v1 |
| [ADR-011](adr/011-coordination-level-strategy.md) | Coordination Levels | L1/L2/L3 coordination strategy |
| [ADR-012](adr/012-governance-rationalization.md) | Governance Rationalization | Two-tier policy, /onboard skill, eliminated duplicate RULES.md |
| [ADR-013](adr/013-extended-skills.md) | Extended Skill Additions | /onboard, /review, /hitl skills — rationale and agent assignments |
| [ADR-014](adr/014-multi-agent-installer.md) | Multi-Agent Installer v0.2 | Runtime registry, namespace translation, and capability-aware install model |

**Key Design Principles**:

1. **Skill as Source of Truth**: Full instructions live in skill SKILL.md; agents are thin wrappers
2. **Load at Spawn**: Skills are loaded/injected into agent context at spawn (not invoked at runtime)
3. **Two Invocation Paths**: User invokes skill directly (`/spec` with `context: fork`) OR orchestrator spawns agent (loads via `skills:` list)
4. **Blocking Reminders**: SubagentStop/Stop hooks can block and prompt for action; agent decides response
5. **HITL via Structured Block**: Sub-agents return `## QUESTIONS FOR USER` block; orchestrator relays via `AskUserQuestion`
6. **Evidence-Based Standards**: `/onboard` derives standards from codebase observation, not aspirational templates

---

## Security Considerations

### Secrets Management

- No secrets in skill/agent files
- Environment variables for API keys
- `.serena/` excluded from git (transient data)

### Permission Model

- `permissionMode: default` for most agents
- `permissionMode: plan` for Deployer (requires approval)
- `disallowedTools` to restrict dangerous operations

### Content Filtering

- Deferred to v1 (Guardrails hook)
- Current: Rely on Claude's built-in safety

---

## Performance Considerations

### Token Efficiency

- Skills are loaded on demand
- Agent context forking isolates state
- Distill skill for context reduction
- Policy loading via `@`-references (not full injection)

### Parallel Execution

- Workflow engine runs independent steps in parallel
- Wave → Checkpoint → Wave pattern
- Agent orchestration via Task tool batching

---

## Appendix: Component Inventory

### Files (Source: package/)

| Category | Count | Components |
|----------|-------|------------|
| Agents | 7 | business-analyst, architect, project-manager, developer, validator, deployer, tech-writer |
| Skills (user-invocable) | 16 | orchestrate, spec, design, plan, implement, validate, deploy, document, onboard, review, reflexion, reflect, optimize, analyse, research, distill |
| Skills (protocol) | 1 | hitl |
| Hooks | 7 | inject-context.sh, remind-validate.sh, remind-reflexion.sh, remind-reflect.sh, checkpoint-session.sh, setup-project.sh, hook-utils.sh |
| Policy | 2 | RULES.md, PRINCIPLES.md |
| Workflows | 2 | SWE.md, meta-learning.md |
| Templates | 11 | vision.md, blueprint.md, prd.md, architecture.md, adr.md, roadmap.md, backlog.md, issues.md, standards.md, guidelines.md, knowledge.md |
| Settings | 2 | settings.json, mcp.json |
| **Total** | **~52** | |

### Dependencies

| Dependency | Type | Classification |
|------------|------|----------------|
| Claude Code | Runtime | Required |
| Serena MCP | MCP Server | Required |
| Bash | Shell | Required (hooks) |
| Context7 MCP | MCP Server | Recommended |
| DeepWiki MCP | MCP Server | Recommended |
| Parallel Search MCP | MCP Server | Recommended |
| Parallel Task MCP | MCP Server | Recommended |
| Playwright MCP | MCP Server | Optional |

---

## Next Steps
