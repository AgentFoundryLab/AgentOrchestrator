---
name: review
description: >-
  Review any repository surface for consistency, correctness, and completeness.
  Use when asked to review code, tests, docs, config, scripts, committed or
  uncommitted changes, or cross-surface consistency between them, especially
  contradictions between explicit requirements, implicit assumptions, claimed
  capabilities, established patterns, abstractions, and implementations.
  Triggers on: "review this", "audit my changes", "check consistency",
  "review docs", "review tests", "review config", "review committed changes",
  "review uncommitted changes", or any request to inspect repository work for
  bugs, regressions, omissions, or mismatches.
argument-hint: optional scope — path, diff range, artifact, or focus area
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
context: fork
agent: tech-writer
---

# /review - Repository Review

Use this skill for repository reviews of any kind, not just code diffs. On the Full and Medium workflow depths it runs between `$planner` and `$implement` as the cross-artifact gate; it is equally valid standalone on any surface.

## Scope Rules

- Review the whole relevant surface: committed changes, staged changes, unstaged changes, untracked files, and surrounding impacted files when consistency depends on them.
- Do not limit to code if the change also affects tests, docs, config, scripts, schema, or ops artifacts.
- If the user gives a narrow scope, stay within it. Otherwise prefer the full relevant blast radius.

## Local Conventions

- Take repository conventions from the active repo `AGENTS.md` and `docs/policy/STANDARDS.md` — language, formatting, export style, file layout, route conventions. Never assume a stack; read what this repo actually declares.
- Review docs against the repo's own ownership model, not generic documentation instincts.
- Record ids are immutable. Renumbering, recycling, or retyping `REQ`/`AC`/`TR`/`TRC`/`FBP`/`ADR`/`WO`/`ISS`/`REG`/`TD`/`FB` is a finding. So is an out-of-vocabulary `category`/`scope`/`severity`/`priority` value, or a status outside the type's own set — this package has no allocator to refuse them at write time, so this review is the gate.

## Review Principles

- Prefer deletion over addition: best part is no part. Flag unnecessary files, flows, helpers, layers, fallbacks, aliases, docs, or abstractions when removal would preserve the explicit contract and reduce conflict.
- Treat explicit user-confirmed requirements as the main drivers. On conflict among code, docs, tests, and patterns, rank the directly confirmed requirement above inferred convenience or existing implementation habit.
- Challenge implicit or weak requirements. Do not accept behavior as required merely because a test, helper, TODO, old doc, or current implementation implies it; identify the unsupported assumption and recommend confirmation, reconciliation, or removal.
- Treat complicated design as a symptom. Extra branching, duplicate state, adapter chains, compatibility shims, broad option objects, and special-case workflows often signal unresolved requirement, capability, or ownership contradictions.
- Require abstractions to simplify. A proper abstraction reduces concepts, call-site conditionals, duplication, and policy leakage while matching the domain boundary. If an abstraction hides mismatch or adds indirection without simplification, report it.

## Review Workflow

1. Establish scope with repository evidence. Start with `git status`, then inspect `git diff --cached`, `git diff`, and relevant untracked files.
2. Expand to neighboring surfaces. Check whether docs, tests, config, scripts, or runtime contracts should have changed together.
3. Check local information flow. Validate the relevant source-of-truth chain before judging consistency:
   - `docs/requirements/` (`FRD-*`, `TRD-*`) defines what must exist
   - `FBP` blueprints and their ADRs define the target design
   - `docs/policy/GUIDELINES.md` defines target-state policy
   - `docs/knowledge/runbooks/` define operational execution
   - `docs/development/WORKORDERS.md` and `status/STATUS.md` track requirement-versus-code reality
   - `docs/development/ISSUES.md` tracks defects and architecture-versus-code drift

   Separate directly confirmed requirements from implicit assumptions before judging conflicts.
4. Map contradictions across requirement, capability, pattern, and implementation layers. Check whether each claimed capability is implemented, tested, documented in the right place, and consistent with the established pattern.
5. Review for four things: consistency, correctness, completeness, unnecessary complexity.
6. Validate the risky claims. Run the narrowest relevant tests, commands, or scenarios when possible.
7. Report findings first.

## Cross-Artifact Gate

When invoked as the planning gate between `$planner` and `$implement`, also verify:

- Every `REQ` has a blueprint path and at least one Work Order
- Every `AC`/`TRC` traces to a Work Order and to validation coverage
- No ADR contradicts its governing blueprint, ADR tiers match the blueprints they govern, and ADRs are not mixed with TDRs
- `ROADMAP.md`, the `PLAN` documents, and `WORKORDERS.md` agree on phase and Milestone placement
- Complex Work Orders are safe to delegate because their implementation plan is discoverable and linked
- Blocking gaps are surfaced before implementation begins

Log blocking gaps as `ISS`/`TD` records and route them through `$reconcile` before `$implement` starts.

## What To Look For

### Consistency

- docs disagree with code or tests
- tests encode behavior different from requirements or runtime docs
- config or env assumptions differ across files
- naming, route, flag, webhook, schema, or provider contracts drift across the repo
- information written in the wrong layer, e.g.:
  - requirements containing implementation-state claims
  - architecture containing operational steps better suited for runbooks
  - runbooks contradicting code or provider reality
  - status claiming behavior not proven by code or tests

### Contradictions and Conflicting Signals

- explicit requirements conflict with inferred behavior, old tests, legacy docs, or convenience-driven code
- docs claim a capability, option, route, role, or workflow that code cannot actually perform
- tests assert behavior not supported by requirements, architecture, or real provider/runtime behavior
- implementation introduces aliases, fallbacks, mappings, or compatibility paths that mask a source-of-truth conflict
- two patterns solve the same problem differently without a stated migration or boundary
- an abstraction adds vocabulary, branching, or lifecycle states instead of simplifying the caller and domain model
- a "small fix" expands scope because it preserves an unnecessary part rather than removing it

### Correctness

- bugs
- regressions
- invalid assumptions
- unsafe defaults
- incorrect command sequences
- mismatched provider or framework behavior

### Completeness

- missing tests for changed behavior
- missing docs for operator-visible or developer-visible changes
- missing config, env, migration, or rollout handling
- partially implemented flows presented as complete
- missing propagation across the doc flow, e.g. requirement → architecture → task/status/runbook where the change clearly requires it
- missing deletion or simplification when keeping both old and new surfaces creates contradictory requirements, capabilities, patterns, or implementations

## Outputs

- Findings in the response, ordered by severity.
- A review report at `docs/analysis/review-YYYY-MM-DD.md` when the review is broad or its findings must outlive the session.
- Blocking issues logged as `ISS`/`TD` records with their own documents, plus index rows.

## Reporting Rules

- Findings are the primary output.
- Order findings by severity.
- Use file references with line numbers when possible.
- Keep summaries brief and secondary.
- If no findings, say so explicitly and still mention residual risks or test gaps.
- Call out uncertainty instead of guessing.

## Hard Truth Rules

- "Docs-only" changes can still be wrong if they describe fake procedures.
- Passing tests do not make a review complete if docs, config, or runtime contracts drifted.
- A narrow diff can still require wider review if it changes a shared contract.
- Consistency includes source-of-truth placement and information flow, not just matching strings.
- If the simplest correct fix is removal, do not recommend extra abstraction, fallback, or compatibility plumbing.
- Complexity without clearer behavior is evidence of unresolved conflict, not proof that the domain requires complexity.
