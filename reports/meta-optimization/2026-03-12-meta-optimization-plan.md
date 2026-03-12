---
date: 2026-03-12
type: meta-optimization
status: proposed
scope: task-context-resolution
---

## Summary

The runtime skill stack still assumes `docs/development/BACKLOG.md` is both task index and execution contract. This repository no longer works that way.

Current project state already splits those roles:
- `docs/development/BACKLOG.md` is the canonical task index
- `docs/development/tasks/*.md` hold active task details
- `docs/development/archive/` holds completed task details

That creates a concrete orchestration risk:
- `/orchestrate` reads backlog table only
- `/implement` still extracts acceptance criteria from backlog
- `/validate` still treats backlog as the default AC source
- `/review` still describes backlog as executable task detail
- `/plan` and `backlog.md` template still teach the old embedded-detail model

This is not a theoretical inconsistency. The runtime instructions and templates now contradict the project's own documented artifact rules.

## Evidence

Primary evidence used:
- `docs/development/BACKLOG.md`
- `docs/development/tasks/INDEX.md`
- `docs/development/tasks/v0.md`
- `/home/vscode/.agents/skills/orchestrate/SKILL.md`
- `/home/vscode/.agents/skills/plan/SKILL.md`
- `/home/vscode/.agents/skills/implement/SKILL.md`
- `/home/vscode/.agents/skills/validate/SKILL.md`
- `/home/vscode/.agents/skills/review/SKILL.md`
- `/home/vscode/.agents/templates/backlog.md`
- `/home/vscode/.agents/templates/issues.md`
- `package/workflows/meta-learning.md`

Observed contradictions:
- `docs/development/tasks/INDEX.md` says backlog is the canonical task index and per-milestone task docs store active details.
- `docs/development/BACKLOG.md` already follows that model and links to external task-detail files.
- `/orchestrate` says to read `docs/development/BACKLOG.md` task table only.
- `/implement` says "From BACKLOG.md, extract" task description and acceptance criteria.
- `/validate` uses BACKLOG as the default acceptance-criteria source.
- `/review` says backlog captures executable task detail.
- `/plan` still generates backlog-embedded `Task Details`.
- `backlog.md` template still hardcodes embedded task details as the default shape.

Evidence gaps:
- The prior draft cited `reports/reflection/2026-03-12-meta-optimization-plan.md`, but that file does not exist.
- Serena project memories were unavailable in this workspace because onboarding has not been performed yet.

## Proposals

### Proposal 1: Add a Global Artifact-Role Rule

**Target**: runtime `RULES.md` and matching package source  
**Pattern**: skills are making incompatible assumptions about artifact roles.  
**Current**:
- no single rule defines backlog vs task-detail doc responsibilities
- local repo already documents a split model, but runtime skills do not share it

**Proposed**:
- add one explicit rule:
  - `ROADMAP` = strategic direction and sequencing
  - `BACKLOG` = task index, status, traceability, refs
  - task-detail docs = execution contract for complex work
  - `ISSUES` = problem records, not execution specs
- require downstream skills to follow that rule

**Rationale**:
- prevents further drift between templates, skills, and project docs

**Risk**: Medium

### Proposal 2: Update `backlog.md` to Support Ref-Based Task Resolution

**Target**: `/home/vscode/.agents/templates/backlog.md`  
**Pattern**: template still teaches backlog-embedded task details only.  
**Current**:
- table plus mandatory `## Task Details`
- no place for canonical task-detail references

**Proposed**:
- extend task table or per-task metadata with:
  - `Canonical Refs`
  - `Dependency Refs`
  - `Evidence Refs`
- keep embedded task details optional for simple tasks only
- add role note:
  - backlog is the task index by default
  - external task docs are preferred for complex tasks

**Rationale**:
- aligns the template with how this repo already operates
- preserves simple embedded tasks where the lighter model is sufficient

**Risk**: Medium

### Proposal 3: Add a Generic Task-Detail Template

**Target**: runtime templates set and matching package source  
**Pattern**: external task-detail docs exist in practice but have no standard template.  
**Current**:
- roadmap/backlog/issues templates exist
- no template for the canonical execution-contract document

**Proposed**:
- add a `task-detail.md` template with:
  - Goal
  - In Scope
  - Out of Scope
  - Acceptance Criteria
  - Dependencies
  - Required Shape
  - Evidence Refs
  - Known Traps
  - Change Log

**Rationale**:
- prevents ad hoc task-doc structures
- gives orchestrator, implementer, and validator a stable target

**Risk**: Low

### Proposal 4: Update `/plan` to Generate Ref-Aware Backlogs

**Target**: `/home/vscode/.agents/skills/plan/SKILL.md`  
**Pattern**: planning skill still teaches backlog-embedded details as the default output.  
**Current**:
- `/plan` output is only ROADMAP + BACKLOG
- workflow and template examples generate `## Task Details` inside backlog

**Proposed**:
- change `/plan` guidance to support two valid modes:
  - simple mode: embed task details in backlog
  - complex mode: generate task-detail docs and link them from backlog
- require planner to choose explicitly rather than mixing both accidentally
- add rule:
  - if a milestone has many tasks or long AC blocks, externalize details

**Rationale**:
- fixes the problem at the source instead of only compensating later in `/orchestrate`

**Risk**: Medium

### Proposal 5: Add a Ref-Resolution Gate to `/orchestrate`

**Target**: `/home/vscode/.agents/skills/orchestrate/SKILL.md`  
**Pattern**: orchestrator delegates from backlog index without resolving authoritative task context.  
**Current**:
- `What to Read` says backlog task table only
- details are delegated too late, after task selection pressure already exists

**Proposed**:
- keep high-level reading discipline for workflow selection
- add mandatory pre-implementation gate:
  1. identify candidate task
  2. resolve canonical task-detail refs if present
  3. load only the narrowest authoritative section
  4. build a minimal worker brief from that source
  5. delegate
- add hard-stop behavior:
  - if the task is complex and no authoritative detail source is discoverable, stop and report incomplete execution context

**Rationale**:
- preserves lean orchestration context while removing the current delegation hazard

**Risk**: High

### Proposal 6: Make `/implement` Treat Backlog as Locator First

**Target**: `/home/vscode/.agents/skills/implement/SKILL.md`  
**Pattern**: implementer still assumes backlog directly contains the execution contract.  
**Current**:
- inputs say backlog is for task details
- step 2 says to extract AC from backlog

**Proposed**:
- change input wording:
  - backlog = task lookup and refs
  - canonical task-detail source = detailed scope and AC when present
- change step 2 to:
  - resolve canonical refs first
  - use backlog details only when no stronger task contract exists
- require worker brief to include:
  - goal
  - scope/non-goals
  - AC
  - dependencies
  - evidence refs

**Rationale**:
- adds defense in depth even if orchestrator handoff is weak

**Risk**: Medium

### Proposal 7: Make `/validate` Validate Against the Canonical Contract

**Target**: `/home/vscode/.agents/skills/validate/SKILL.md`  
**Pattern**: validator can pass work against underspecified backlog text.  
**Current**:
- BACKLOG is the default AC source
- validation flow does not distinguish backlog index from execution-contract docs

**Proposed**:
- add canonical task-detail refs as an explicit validation input
- require validator to prefer authoritative task-detail docs over backlog summaries
- add evidence rule:
  - if stronger refs exist, validation against backlog text alone is insufficient

**Rationale**:
- prevents false-positive validation on incomplete scope

**Risk**: Medium

### Proposal 8: Make `/review` Flag Delegation-Unsafe Task Definitions

**Target**: `/home/vscode/.agents/skills/review/SKILL.md`  
**Pattern**: review checks traceability but not whether tasks are safely executable by downstream agents.  
**Current**:
- review still states backlog captures executable task detail
- no check for complex task refs

**Proposed**:
- change artifact-role language to match the split model
- add blocking check:
  - every complex backlog task must either contain executable detail or resolve to a canonical task-detail source
- add blocking finding type:
  - `delegation-risk`

**Rationale**:
- catches the mismatch before implementation starts

**Risk**: Low

### Proposal 9: Clarify `issues.md` as Problem Record, Not Spec

**Target**: `/home/vscode/.agents/templates/issues.md`  
**Pattern**: issue docs can drift into pseudo-specs when task docs are weak.  
**Current**:
- template has strong issue detail sections
- no explicit boundary between issue records and execution contracts

**Proposed**:
- add guidance:
  - issues record symptoms, impact, workaround, and resolution path
  - issues may reference backlog and task-detail docs
  - issues are not execution specs unless explicitly elevated and linked

**Rationale**:
- reduces artifact-role confusion under pressure

**Risk**: Low

## Implementation Order

1. Add the global artifact-role rule.
2. Update `backlog.md` and add `task-detail.md`.
3. Update `/plan` so new plans generate the right artifact shape.
4. Update `/orchestrate` with ref-resolution gating.
5. Update `/implement` and `/validate` to consume canonical refs.
6. Update `/review` to block unsafe task definitions.
7. Clarify `issues.md`.
8. Re-run a focused cross-artifact review after rollout.

## Rollback Plan

- Revert skill changes in reverse dependency order:
  1. review
  2. validate
  3. implement
  4. orchestrate
  5. plan
- Revert template changes:
  1. issues
  2. backlog
  3. task-detail
- Revert the global artifact-role rule last if the broader model must be abandoned.

## Approval Boundary

This report proposes changes only. No runtime skills, templates, or policy files were modified.
