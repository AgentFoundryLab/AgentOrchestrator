---
name: status-update
description: >-
  Assess requirements, blueprints, Work Orders, implementation, tests, and validation evidence against the current codebase, then set implementation status in the record indexes without touching external spreadsheets unless the user explicitly asks for a sync skill.
argument-hint: WO, REQ/TR, AC/TRC, feature, file, or release scope
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
context: fork
agent: validator
---

# Status Update

- Use this skill for implementation assessment and local status evidence, not external workbook/sheet sync.
- `$status-update` owns implementation assessment: it sets each assessed record's status in its index, reconciles the authored docs that describe delivered behavior, and makes the post-validation status commit. **No other stage sets status.**

## Status store

The versioned planning docs are the source of truth for status — there is no separate database:

| Record | Status lives in | Vocabulary |
|---|---|---|
| `WO` | `docs/development/WORKORDERS.md` | `Open` \| `Implementing` \| `Validating` \| `Validated` \| `Deferred` \| `Closed` \| `Decommissioned` \| `Blocked` |
| `REQ` `AC` `TR` `TRC` | `docs/requirements/REQUIREMENTS.md` | `Not Implemented` \| `Partial` \| `Implemented` \| `Postponed` \| `Decommissioned` |
| `ISS` `REG` | `docs/development/ISSUES.md` | per the record's own document |
| `TD` | `docs/development/TECH_DEBT.md` | `Open` \| `Deferred` \| `Closed` \| `Decommissioned` |
| `FB` | `docs/development/FEEDBACK.md` | triage lifecycle — **not assessed here** |
| Milestone | its `PLAN-NNN` document | gate passed / not passed |
| Rollup | `docs/development/status/STATUS.md` | derived from the above |

- Use **only** the type's own vocabulary. Never invent a value, and never convert `Decommissioned` to `Postponed`.
- `Blocked` requires at least one blocker id in the same edit. `Deferred` is non-terminal: the record stays in the active index and still accepts links.
- **`FB` carries no implementation-status verdict.** Its lifecycle is triage-driven and owned by `$reconcile`, not assessed here.
- Edit only the status field and the assessment prose that belongs to it. Never renumber, recycle, or rewrite an immutable id. Pushing status to an external sheet is a separate sync skill's job, not this one's.

## Inputs

- Use active repo `AGENTS.md` for concrete paths, status artifacts, verify commands, validation gates.
- Typical source surfaces:
  - requirements under `docs/requirements/` (`FRD-*`, `TRD-*`) plus the `REQUIREMENTS.md` index;
  - blueprints under `docs/architecture/{foundation,feature,system}/` and ADRs under `docs/architecture/ADR/`;
  - the plan: `docs/development/ROADMAP.md`, `plans/PLAN-*.md`, `workorders/WO-*.md`, `WORKORDERS.md`;
  - feedback: `issues/ISS-*.md`, `issues/REG-*.md`, `debt/TD-*.md`, `feedback/FB-*.md` plus their indexes;
  - implementation code, schema, routes, UI, jobs, providers, flags, tests;
  - validation coverage under `docs/validation/`.

## What each value means

The table above owns *which* values each type accepts. This is what they mean:

- **`Implemented` / `Validated`** — the required behavior exists in the codebase with credible runtime or test evidence.
- **`Partial`** — some meaningful portion exists, but a required path, enforcement layer, provider, persistence boundary, or verification proof is still missing.
- **`Postponed` / `Deferred`** — intentionally set aside by a product or stakeholder decision. Not an implementation assessment, and non-terminal: the record stays active.
- **`Decommissioned`** — an immutable record intentionally retired, split, merged, moved, or superseded. Stays traceable without being assessed as active scope.
- **`Not Implemented` / `Open`** — behavior absent, or only described in docs with no implementation proof.
- **`Blocked`** — cannot proceed; requires blocker ids in the same edit.

Never invent an intermediate value, and never convert `Decommissioned` to `Postponed`.

## Workflow

1. Identify scope first.
   - If the user names a `WO`, `REQ`/`TR`, `AC`/`TRC`, feature, file, PR, or release activity, keep the assessment scoped to that target.
   - If the user does not specify scope, review all relevant requirement, Work Order, and feedback records against the current codebase.
2. Read only the requirement, blueprint, Work Order, issue/regression, and status records the scope needs. Query indexes by scoped id — never read a large index wholesale.
3. Inspect implementation evidence in code and tests.
4. Run the narrowest real test or scenario when a code or evidence change needs validation.
5. Set the assessed status on each in-scope record in its index. For a `Blocked` Work Order, record the blocking ids in the same edit — `blockers` is an id list, never prose. Close a `WO` only after validation passes and the user accepts. Close an `ISS` only after every `REG` linked to it is closed. Do not upgrade a parent `REQ` while a required child `AC` is still materially missing.
6. Reconcile authored living docs against assessed reality. `README.md` and `docs/**` prose are hand-written and drift from the code they describe; update drifted sections to match what was delivered. If a doc reveals the requirement itself is wrong — not just stale prose — route through `$reconcile` → `$spec` rather than editing scope here. Reuse the `git:update-docs` skill for the drift pass when available.
7. Before any closure or upgrade, verify each linked `REG`'s **closure matrix** is complete and passing. Active linked regression evidence blocks `Implemented`, `Validated`, and `Closed`. Broken-behavior characterization is evidence only and never counts as acceptance coverage.
8. Refresh `docs/development/status/STATUS.md` and the header counters on the indexes you touched (`Updated:` date, done/total tallies) so no index contradicts its own rows.
9. Commit the status change atomically before handoff when rows changed — stage explicit files only (the indexes touched, `STATUS.md`, any updated authored docs), citing the record ids whose state moved.
10. Stop before any external sheet/workbook write unless the user explicitly asks for the sync skill.
11. Finalization hygiene (delivery-run close): once integration has landed, hand off to (or run) `$cleanup` to prune merged worktrees and delivery branches, and to triage any worktree with unmerged commits or uncommitted changes — never delete unmerged/uncommitted work; surface it for a merge or discard decision.

## Assessment rules

- Prefer repo-visible proof over architectural intent.
- Tests count as strong evidence only if they exercise the claimed behavior.
- Broken-behavior characterization tests document regressions but do not prove corrected acceptance behavior.
- Documentation alone is not implementation.
- Environment failures are real. If a code path exists but fails in the current environment, the status is usually `Partial`, not `Implemented`.
- Do not upgrade or close records while linked reported regression bullets or examples remain unmapped to passing corrected `AC`/`TRC` validation.
- Derive every count and scope claim from the doc at authoring time, not from recall — a remembered figure reports a narrower state than the one that exists.

## Editing rules

- Update only the relevant status rows. Do not mass-rewrite unrelated assessments.
- Keep validation proof where it belongs — the coverage document under `docs/validation/`, the `WO`/`ISS` document, and git history — not stuffed into an index status field, which carries status and, for a blocked `WO`, its blocker ids.
- Use the repo's existing status fields rather than inventing a new schema.
- Preserve release-plan ordering, immutable ids, links, owners, priorities, and dependencies.
- Do not edit a `REG`'s `Reported behavior` to make closure easier; update the corrected coverage and status while preserving the report verbatim.
- This stage never renumbers, recycles, retracts, or relinks a record. Relinking a `REG` and reclassifying an `ISS` are `$reconcile`'s dedicated operations, not generic status edits.

## Reporting rules

- The final status must state `VALIDATED` or `NOT VALIDATED: <exact missing/failing gate>` when status-update is part of delivery closeout.
- Call out uncertainty explicitly.
- If evidence is mixed, say so and keep the row at `Partial`.
- If tests or verify commands cannot run, state that as a blocker in the status evidence and the final report.
- Report hard truth: the index can be internally consistent while its assessment content is stale.
