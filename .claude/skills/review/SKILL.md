---
name: review
description: Analyze cross-artifact consistency, correctness, and coverage
argument-hint: optional focus area (PRD, ARCH, BACKLOG)
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - AskUserQuestion
context: fork
agent: tech-writer
---

# /review - Cross-Artifact Review

Analyze consistency, correctness, and coverage across all planning artifacts.

## Purpose

After `/plan` and before `/implement`, ensure:
- Every FR has architecture components and BACKLOG tasks
- Every user story traces to acceptance criteria and tasks
- No ADR contradicts ARCHITECTURE
- ROADMAP and BACKLOG are aligned
- Blocking gaps are surfaced before implementation begins

## Inputs

- `$ARGUMENTS`: Optional focus area (PRD, ARCH, BACKLOG) — default: all
- PRD: `docs/architecture/PRD.md`
- Architecture: `docs/architecture/ARCHITECTURE.md`
- ADRs: `docs/architecture/adr/`
- ROADMAP: `docs/objectives/ROADMAP.md`
- BACKLOG: `docs/development/BACKLOG.md`

## Outputs

Review report at `reports/analysis/review-YYYY-MM-DD.md`

Blocking issues also logged to `docs/development/ISSUES.md`.

## Workflow

### 1. Load All Artifacts
Read PRD, ARCHITECTURE.md, all ADRs, ROADMAP.md, BACKLOG.md.
Extract: FRs, NFRs, user stories, components, ADR decisions, milestones, tasks.

### 2. Consistency Check
Cross-check:
- Every FR → has at least one architecture component
- Every FR → has at least one BACKLOG task
- Every BACKLOG task → traceable to an FR or NFR
- ROADMAP milestones → match BACKLOG milestone groupings

### 3. Correctness Check
- Each ADR status (Accepted/Proposed) — does ARCHITECTURE reflect it?
- No ADR contradicts the final design in ARCHITECTURE.md
- Task acceptance criteria match the FR they trace to

### 4. Coverage Check
- Every user story → has AC → has at least one task covering it
- No orphaned tasks (tasks with no FR/NFR traceability)
- No FRs without test coverage plan in BACKLOG

### 5. Produce Report

```markdown
# Cross-Artifact Review — YYYY-MM-DD

## Summary
[Overall status: Clean / Issues Found]

## Validation Checklist
- [ ] All FRs have ARCHITECTURE components
- [ ] All FRs have BACKLOG tasks
- [ ] All BACKLOG tasks traceable to FR or NFR
- [ ] No ADR contradicts ARCHITECTURE
- [ ] ROADMAP and BACKLOG are aligned
- [ ] Blocking issues logged to ISSUES.md

## Gaps & Inconsistencies

### Blocking Issues
| ID | Type | Description | Recommendation |
|----|------|-------------|----------------|
| R-001 | [Consistency/Coverage/Correctness] | [Details] | Re-run /[agent] |

### Non-Blocking Issues
| ID | Type | Description | Note |
|----|------|-------------|------|
| R-002 | [Type] | [Details] | [Note] |

## Traceability Matrix
| FR | Component | Task(s) | Status |
|----|-----------|---------|--------|
| FR1 | [comp] | T-001, T-002 | OK |
| FR2 | — | — | MISSING |
```

### 6. Handle Blocking Issues
If blocking issues found:
- Log each to `docs/development/ISSUES.md`
- In report, recommend which agent to re-invoke (e.g., "Re-run /design for missing component")
- Return QUESTIONS block to Orchestrator if human decision needed

Non-blocking issues: note in report only, do not block.

## Validation Checklist
- [ ] All FRs have ARCHITECTURE components
- [ ] All FRs have BACKLOG tasks
- [ ] All BACKLOG tasks traceable to FR or NFR
- [ ] No ADR contradicts ARCHITECTURE
- [ ] ROADMAP and BACKLOG are aligned
- [ ] Blocking issues logged to ISSUES.md
- [ ] Report written to `reports/analysis/review-YYYY-MM-DD.md`
