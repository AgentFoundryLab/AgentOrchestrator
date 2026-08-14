---
name: implement
description: Implement a backlog task with code and tests
argument-hint: Work Order id, implementation-plan path, or description
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - TaskCreate
  - TaskUpdate
  - TaskList
  - AskUserQuestion
context: fork
agent: developer
---

# /implement - Task Implementation Procedure

- Follows the global policy loaded from the active runtime root's `policy/` directory (`PRINCIPLES.md`, `RULES.md`). Active repo `AGENTS.md` defines local task paths, commands, validation gates, git rules, and delivery requirements.

## Purpose

Implement the assigned task or implementation slice by:
- reading the Work Order and its implementation plan first;
- following the linked architecture and requirements;
- refusing domain/data model changes that lack explicit Architect adversarial validation;
- deriving tests from the acceptance criteria the task references;
- completing scoped production behavior without TODOs, placeholders, or speculative fallback paths;
- committing the scoped implementation before handoff to validation when a valid increment exists.

## Workflow

1. Resolve the target task from `$ARGUMENTS` or the orchestrator brief.
2. Read active repo rules, the Work Order, its implementation plan, and the blueprints and requirements needed to implement the slice. Work Orders cross-reference requirements by id only — open the owning `FRD`/`TRD` under `docs/requirements/` and read the referenced `REQ`/`AC`/`TR`/`TRC` text verbatim, and implement against that text, never against the WO's brief id-description or a guessed requirement. Use `$context-compiler` to hydrate the bundle when the slice spans several requirements.
3. Confirm real HTTP/API/network integrations against the live endpoint before writing code.
4. Before schema, seed, runtime model, lifecycle/status, source-of-truth, alias, or fallback changes, verify the task cites explicit Architect adversarial validation; otherwise stop and route back through `$reconcile` to `$architect`/`$planner`.
5. For regression fixes, preserve the original regression evidence in `docs/development/ISSUES.md` and follow TDD-first order: characterize the broken behavior with tests that pass against the current regression, update the corrected acceptance criteria and tests so they fail, implement, then rerun until green.
6. Implement incrementally with focused checks after each isolated change.
7. Stop and escalate, or route through `$reconcile`, when the task, architecture, requirements, and code reality conflict.
8. Before handoff, run the focused validation required for the implementation slice. If it needs the app or its stores, boot them only through the repo's own isolated launch path, which sources `.orchestrator.env` (`ORCHESTRATOR_WT` prefix + `ORCHESTRATOR_SHIFT_INDEX`); a vendor's or framework's own start command binds fixed ports and one shared instance, rejoining the lane the isolation exists to separate. Stop what you booted through that repo's stop path and report any port or store left live.
9. Commit atomically:
   - run `git status`;
   - stage explicit files only — never `git add .` or `git add -A`;
   - commit only the scoped implementation increment, citing the task id in the subject;
   - report commit SHA, checks run, blockers, skipped scope, residual risk.
10. Hand off to `$validate` or the orchestrator. If no valid implementation increment exists, report why no commit was made.

## Delegated-slice rules

- Follow the orchestrator brief's owned files/surfaces, exclusions, and validation expectations.
- Do not redefine scope, perform final task validation, run status/PR continuation, merge, or deploy unless explicitly assigned.
- Do not introduce hacky workarounds, outdated/contradicting fallbacks, alias mappings, lifecycle inventions, or on-the-spot schema changes to bypass a missing gate.
- Do not revert or reformat unrelated parallel-agent work.

## Checkpoint discipline

- Commit plus a status note at each meaningful increment, not one big-bang at the end.
- When the context budget runs low, checkpoint the WIP first — commit what exists with a message naming completed vs remaining work — rather than spending the last budget on more edits.
- Name the last checkpoint commit and the done/remaining split in the final report.

## Checklist

- [ ] Active repo `AGENTS.md` was read.
- [ ] Work Order / brief and its implementation plan were read first.
- [ ] Referenced requirement text was read from the owning `FRD`/`TRD`, not inferred from the Work Order.
- [ ] Tests/checks map to the referenced acceptance criteria or assigned behavior.
- [ ] Changes follow the governing architecture and ADRs.
- [ ] Domain/data model changes have explicit Architect adversarial validation.
- [ ] Regression fixes preserve reported evidence and follow TDD-first corrected-criteria validation.
- [ ] Focused validation ran for the implementation slice.
- [ ] Scoped implementation was committed before validation handoff, or the exact no-commit blocker was reported.
- [ ] Every service and store this lane booted is stopped, or named as still live.
