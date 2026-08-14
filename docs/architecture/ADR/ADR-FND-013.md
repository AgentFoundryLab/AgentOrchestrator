# ADR-FND-013: Extended Skill Additions (onboard, review, hitl)

**Status**: Accepted
**Date**: 2026-02-19
**Context**: v0.1.1/governance-quality-controls branch — extending the skill system beyond the v0 MVP

---

## Context

After v0.1.0 shipped with 14 skills (7 agent-backed + 1 orchestration + 6 utility), three gaps were identified:

1. **Governance bootstrapping**: New projects using Orchestrator had no mechanism to generate project-specific standards. The only policy templates were static placeholders that produced generic, aspirational content regardless of codebase.

2. **Cross-artifact validation gap**: The SWE workflow moved from `/plan` directly to `/implement` with no gate to verify that FRs, architecture components, and BACKLOG tasks were consistent. Silent coverage gaps caused implementation to diverge from requirements.

3. **HITL fragmentation**: Human-in-the-loop escalation logic was duplicated across `AGENTS.md`, skill instructions, and agent definitions. Sub-agents calling `AskUserQuestion` directly from Task-spawned contexts caused inconsistent behavior. No single source of truth existed.

---

## Decision

Add three skills to the Orchestrator package:

### 1. `/onboard` — Project Onboarding

**Purpose**: Analyze a brownfield project and generate project-specific `STANDARDS.md` and `GUIDELINES.md` from codebase evidence.

**Agent**: Architect (system analysis aligns with architectural responsibility)

**Invocation**: `context: fork` — user-invocable, forks into Architect agent

**Outputs**:
- `docs/policy/STANDARDS.md` (MUST-level project conventions)
- `docs/policy/GUIDELINES.md` (SHOULD-level process guidance)

Both files include version headers with semver for lightweight governance.

**Key constraint**: Standards must be derived from observed codebase patterns — not invented. If insufficient signals exist, `/onboard` reports what was found and omits speculative standards.

### 2. `/review` — Cross-Artifact Review

**Purpose**: Validate consistency, correctness, and coverage across PRD, ARCHITECTURE, ADRs, ROADMAP, and BACKLOG before implementation begins.

**Agent**: Tech Writer (cross-doc consistency checking aligns with `/document` conflict detection)

**Invocation**: `context: fork` — user-invocable, forks into Tech Writer agent

**Position in SWE workflow**: Between `/plan` and `/implement` (blocking gate)

**Outputs**:
- `docs/analysis/review-YYYY-MM-DD.md` (full review report)
- `docs/development/ISSUES.md` (blocking issues only)

**Blocking vs non-blocking**: Issues are classified — blocking issues halt workflow, non-blocking are noted only.

### 3. `/hitl` — HITL Shared Protocol

**Purpose**: Single source of truth for human-in-the-loop escalation from sub-agents.

**Invocation**: `user-invocable: false`, `disable-model-invocation: true` — not a user skill, a protocol definition injected via agent `skills:` list

**Contract**:
- Sub-agents spawned via Task tool MUST NOT call `AskUserQuestion` directly
- When blocked, agents emit `## QUESTIONS FOR USER` block
- Orchestrator detects block, relays via `AskUserQuestion`, re-invokes agent with answers prepended
- Loop repeats until no QUESTIONS block remains

---

## Rationale

### Why Architect for /onboard?

The Architect already handles system design, component analysis, and trade-off evaluation. Project onboarding requires the same skills: reading codebases, identifying patterns, evaluating conventions, and producing technical standards. No new agent is needed.

Alternative considered: Dedicated "Onboarding Agent." Rejected — introduces agent proliferation for a task that fits within Architect's domain. Single-Responsibility Principle satisfied at the agent level (system analysis).

### Why Tech Writer for /review?

The Tech Writer already implements conflict detection in the `/document` skill (detecting decision conflicts, spec drift, cross-doc mismatches). Cross-artifact review is the same capability applied pre-implementation. Reusing the same agent avoids creating a specialized "Reviewer Agent."

Alternative considered: Validator agent. Rejected — Validator is constrained to no Write/Edit tools and focuses on code/test validation, not documentation consistency.

### Why a Non-Invocable Protocol Skill for HITL?

A shared skill (`package/skills/hitl/SKILL.md`) is the lowest-friction single source of truth:
- No runtime invocation overhead
- Injected into agent context via `skills:` list at spawn
- One place to update the protocol
- Can reference it from AGENTS.md, skill docs, and decision records

Alternative considered: Embed HITL rules in each agent definition. Rejected — duplication across 7 agent files, no single update point.

Alternative considered: HITL instructions in AGENTS.md only. Rejected — AGENTS.md is loaded as project context, not reliably into all sub-agent spawns.

### Why /review as a Workflow Gate?

The gap between `/plan` and `/implement` is the highest-leverage point for catching specification drift. Catching a missing FR-to-component mapping at review costs one review cycle. Catching it during implementation or validation costs a full rework loop.

The `/review` skill does not add process bureaucracy for light/medium workflows — it is only mandatory in the full workflow depth where spec-design-plan artifacts exist to review.

---

## Alternatives Considered

### Alternative 1: Static STANDARDS.md Template (for /onboard)

Ship a generic `standards.md` template and document that users should fill it in manually.

**Rejected**: Static templates produce aspirational placeholder content. Projects fill them once and they become stale. Evidence-based generation from codebase analysis produces standards that are immediately relevant and accurate.

### Alternative 2: Merge /review into /validate (for /review)

Add cross-artifact consistency checks to the existing `/validate` skill.

**Rejected**: `/validate` runs post-implementation and focuses on code correctness against acceptance criteria. Cross-artifact review runs pre-implementation and focuses on planning artifact consistency. Different timing, different concern. Merging would conflate two distinct quality gates.

### Alternative 3: Inline HITL in /orchestrate (for /hitl)

Document HITL protocol only in the `/orchestrate` skill instructions.

**Rejected**: The protocol needs to be accessible from sub-agent definitions, not just the orchestrator. Sub-agents must know what format to use when they encounter blocking questions, regardless of whether orchestrate is in context.

---

## Consequences

### Positive

- **Governance bootstrap**: New projects get evidence-based policy from day one, not placeholder templates
- **Specification integrity**: `/review` gate catches planning gaps before implementation begins
- **HITL consistency**: Single escalation protocol across all agents eliminates fragmentation
- **No new agents**: Existing Architect and Tech Writer agents absorb new skills without proliferation
- **Skill count growth is controlled**: 14 → 17 skills (21% growth) for significant functionality gains

### Negative

- **Full workflow lengthens**: Adding `/review` adds one step to the full SWE workflow
- **Architect scope expansion**: Architect now handles both `/design` and `/onboard` — two related but distinct skills
- **Tech Writer scope expansion**: Tech Writer handles `/document` and `/review` — two distinct quality concerns

### Mitigations

- `/review` is only mandatory in full workflow depth — medium and light workflows are unaffected
- Architect and Tech Writer scope expansions are cohesive (system analysis + standards generation; doc writing + doc consistency)
- HITL protocol is non-invocable, adding no complexity to user-facing skill list

---

## Related

- [ADR-004](ADR-FND-004.md) — Skill-Agent invocation patterns (context: fork)
- [ADR-006](ADR-FND-006.md) — Policy modularization (extended by /onboard)
- [ADR-012](ADR-FND-012.md) — Governance rationalization (STANDARDS.md naming)
- `docs/knowledge/decisions/hitl-escalation.md` — HITL decision record
