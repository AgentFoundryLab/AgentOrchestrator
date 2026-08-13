# AgentOrchestrator Contracts

**Version**: 0.1.0
**Date**: 2026-02-19
**Source**: decomposed from the retired `ARCHITECTURE.md`. Governing blueprint: [FBP-FND-001](FBP-FND-001.md).

---

## Skill Frontmatter Interface

Every skill SKILL.md uses the following YAML frontmatter contract:

```yaml
---
name: skill-name                          # Required: lowercase + hyphens
description: What this skill does         # Required: Claude uses for auto-invocation
argument-hint: [arg1] [arg2]              # Optional: shown during autocomplete
disable-model-invocation: false           # Optional: true = only user can invoke
user-invocable: true                      # Optional: false = hide from / menu
allowed-tools: Read, Grep, Bash(git:*)    # Optional: tools Claude can use
model: sonnet                             # Optional: model to use (inherits if omitted)
context: fork                             # Agent-backed: run in forked subagent context
agent: architect                          # Agent-backed: target subagent type
---
```

### Skill Categories and Their Contracts

| Category | `context` | `agent` | `user-invocable` | `disable-model-invocation` |
|----------|-----------|---------|------------------|--------------------------|
| Agent-backed | `fork` | set | `true` | `false` |
| Orchestration | — | — | `true` | `false` |
| Utility | — | — | `true` | `false` |
| Protocol (hitl) | — | — | `false` | `true` |

---

## Agent Frontmatter Interface

Every agent `.md` file uses the following YAML frontmatter contract:

```yaml
---
name: agent-identifier                    # Required: lowercase + hyphens
description: When Claude should delegate  # Required: triggers auto-delegation
tools: Read, Grep, Glob, Bash, Task       # Optional: inherits all if omitted
disallowedTools: Write, Edit              # Optional: tools to deny
model: inherit                            # Optional: sonnet|opus|haiku|inherit
permissionMode: default                   # Optional: default|acceptEdits|dontAsk|bypassPermissions|plan
skills:                                   # Optional: skills to preload into agent context
  - skill-name
hooks:
  Stop:                                   # Fires when agent completes
    - hooks:
        - type: command
          command: "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/remind-validate.sh"
---
```

---

## HITL Escalation Protocol

When a sub-agent (spawned via Task tool) encounters a blocking question requiring user input:

### Agent Output Contract (required format)

```markdown
## QUESTIONS FOR USER

Q1: [Question text] *(Required before proceeding)*
- Option A: [description]
- Option B: [description]

Q2: [Question text] *(Optional — default: [default value])*
- Option A: [description]
- Option B: [description]
```

**Constraints**:
- Minimum 0, maximum 3 questions per block
- Blocking questions marked `*(Required before proceeding)*`
- Optional questions include explicit default
- Agent MUST NOT continue implementation while blocking questions exist

### Orchestrator Relay Contract

When orchestrator detects `## QUESTIONS FOR USER` in agent response:
1. Extract each question
2. Relay via `AskUserQuestion` tool
3. Collect answers
4. Re-invoke same agent with answers prepended as context
5. Repeat until no QUESTIONS block in response

---

## Hook Script Interface

Hook scripts follow bash conventions with stdout as system reminder injection:

```bash
#!/bin/bash
# Script: remind-validate.sh
# Event: SubagentStop (phase 1, stop_hook_active=false)
# Blocking: yes
# Output: Injected as <system-reminder> to agent

cat << 'EOF'
<system-reminder>
[Reminder content visible to agent]
</system-reminder>
EOF
```

### Hook Event Contract

| Variable | Source | Available In |
|----------|--------|-------------|
| `$CLAUDE_PROJECT_DIR` | Claude Code | All hooks |
| `$CLAUDE_SESSION_ID` | inject-context.sh | All hooks (after SessionStart) |
| `$PROJECT_NAME` | inject-context.sh | All hooks (after SessionStart) |
| `$stop_hook_active` | Claude Code | SubagentStop only |

---

## Artifact Schemas

Templates are the source of truth for artifact structure. They live in `package/templates/` and install to `<runtime-root>/templates/` globally and project-locally for the selected runtime.

| Artifact | Output Path | Template | Hydrated By |
|----------|-------------|----------|-------------|
| FRD | `docs/requirements/FRD-<SCOPE>-NNN.md` | `package/templates/frd.md` | `/spec` |
| TRD | `docs/requirements/TRD-<SCOPE>-NNN.md` | `package/templates/trd.md` | `/spec` |
| FBP | `docs/architecture/{foundation,feature}/FBP-<TIER>-NNN.md` | `package/templates/fbp-*.md` | `/architect` |
| ADR | `docs/architecture/ADR/ADR-<TIER>-NNN.md` | `package/templates/adr.md` | `/architect` |
| ROADMAP | `docs/development/ROADMAP.md` | `package/templates/roadmap.md` | `/planner` |
| PLAN | `docs/development/plans/PLAN-NNN-<slug>.md` | `package/templates/plan.md` | `/planner` |
| WO | `docs/development/workorders/WO-NNN.md` | `package/templates/work-order.md` | `/planner` |
| ISSUES | `docs/development/ISSUES.md` | `package/templates/issues.md` | `/review`, various |
| STANDARDS.md | `docs/policy/STANDARDS.md` | `package/templates/standards.md` | `/onboard` |
| GUIDELINES.md | `docs/policy/GUIDELINES.md` | `package/templates/guidelines.md` | `/onboard` |
| VISION | `docs/objectives/VISION.md` | `package/templates/vision.md` | `/spec` |
| BLUEPRINT | `docs/objectives/BLUEPRINT.md` | `package/templates/blueprint.md` | `/spec` |
| Knowledge index | `docs/knowledge/README.md` | `package/templates/knowledge.md` | `/onboard` |
| Review Report | `reports/analysis/review-YYYY-MM-DD.md` | — (free-form) | `/review` |

> **BACKLOG structure**: see [ADR-005](../adr/005-task-decomposition-hierarchy.md) for Milestone → Phase → Epic → Task hierarchy.

---

## Policy File Versioning Contract

Policy files generated by `/onboard` include a version header:

```markdown
**Version**: MAJOR.MINOR.PATCH | **Updated**: YYYY-MM-DD
> Amend with rationale. Bump: MAJOR (breaking), MINOR (additions), PATCH (clarifications).
```

Semver semantics:
- **MAJOR**: Breaking change — removes or contradicts existing standards
- **MINOR**: Addition — new section or standard added
- **PATCH**: Clarification — rewording without meaning change
