---
name: validate
description: Verify implementation against Work Orders, requirements, and blueprints
argument-hint: Work Order id, code area, or artifact path
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

# /validate - Work Order Validation Procedure

- Follows the global policy loaded from the active runtime root's `policy/` directory (`PRINCIPLES.md`, `RULES.md`). Active repo `AGENTS.md` defines local validation gates, evidence artifacts, status rules, commands, and delivery requirements.

## Purpose

Validate the assigned Work Order, implementation commit, or verification slice by:
- checking implementation against the Work Order first, then linked blueprints and requirements;
- mapping linked regression evidence to corrected `AC`/`TRC` coverage before closure;
- running the active repo's required tests and quality checks for the current validation level;
- recording explicit pass/fail evidence in the validation coverage document;
- authoring durable `ISS`/`REG`/`TD` feedback so findings re-enter the workflow via `$reconcile`.

## Evidence surfaces

| Surface | Path | Holds |
|---|---|---|
| Validation coverage | `docs/validation/WO-NNN.md` | one row per `AC`/`TRC` in scope → layer → command → result → proof, or a gap reason |
| Issue (root cause) | `docs/development/issues/ISS-NNN.md` | generalized diagnosis + remediation |
| Regression (symptom) | `docs/development/issues/REG-NNN.md` | verbatim report + reproduction + closure matrix |
| Tech debt (drift) | `docs/development/debt/TD-NNN.md` | blueprint-vs-code gap + removal trigger |
| Indexes | `docs/development/{ISSUES,TECH_DEBT}.md` | one row per record |
| Work Order status | `docs/development/WORKORDERS.md` | owned by `$status-update`, never set here |

- The coverage document is keyed on **`AC`/`TRC` ids, never the Work Order number**. Acceptance criteria outlive the Work Order that delivered them; a file named after a WO becomes unreadable once it closes.
- A criterion with no row is an uncovered criterion, not an implied pass.
- The coverage document records what a run executed. It carries no status verdict for the Work Order itself.

## Workflow

1. Resolve the validation target from `$ARGUMENTS` or the orchestrator brief.
2. Read active repo rules, the Work Order and its implementation plan, the linked blueprints and requirements, and the implementation commit/scope. Requirements are cross-referenced by id only — read the `REQ`/`AC`/`TR`/`TRC` text from `docs/requirements/`, never from the WO's brief descriptions.
3. Choose validation scope by delivery state: default to blast-radius-scoped focused tests/scenarios (touched surface + dependents) after each fix; run full local E2E once as the pre-PR gate, plus preview/release gates per active repo. Under concurrent worktrees, boot the app and its stores via the repo's own isolated launch path, which sources `.orchestrator.env` (`ORCHESTRATOR_WT` prefix + `ORCHESTRATOR_SHIFT_INDEX`) — shifting service ports and prefixing ephemeral stores — so parallel items don't contend. A vendor's or framework's own start command is not that path and never substitutes for it: its defaults bind fixed ports and one shared instance, rejoining the lane the isolation exists to separate. Stop what you booted through that repo's stop path once the gate ends, pass or fail; report any port or store left live.
4. Verify each assigned acceptance criterion with concrete evidence.
5. For linked regressions, complete the `REG` **closure matrix**: each exact reported condition → corrected `AC`/`TRC` → RED evidence → focused post-fix pass → full/preview gate. A missing row is a validation failure. Broken-behavior characterization is evidence only and never counts as acceptance coverage.
6. Fail closed when evidence is missing, stale, generic, only proves broken-behavior characterization, or only partially covers the claim.
   - Read a remote gate's verdict from the job that ran it. An empty query result is unknown, never "no run" — a freshly pushed run is routinely not yet indexed by the key you filtered on, so re-query on another key before concluding. An aggregate roll-up status cannot separate "still running" from "failing": never merge on it and never call a gate red on it alone.
   - A `failure` conclusion names that something failed, never which — read the failing step's log before attributing a cause. A run-level conclusion is not a job-level one; say which you mean.
7. Write or update the coverage document under `docs/validation/`. Every `passed`/`failed` row names the command that produced it; `configured` or `inspected` is never `executed` or `passed`. A gate result is red regardless of whether the root cause is product code, test harness, config, or credential provisioning.
8. Record evidence only at the scope you proved. Before writing a row that covers several criteria, confirm your run actually exercised each one; if it did not, split the rows rather than over-attributing. Cite the proof that ran, not the row that matched.
9. Author durable feedback for findings:
   - **Triage first.** Read `ISSUES.md` and `TECH_DEBT.md` and inspect active records in the same category/scope with their root-cause state and linked `REG` evidence. Two lanes hit the same defect routinely, and an id spent on a duplicate is spent permanently. Similar wording is not proof; grouping requires a defensible common-root-cause judgment.
   - **If no `ISS` owns the cause:** author the generalized `ISS-NNN.md` from `iss.md` with category, scope, `issueType`, severity, and root-cause state, then record the concrete `REG-NNN.md` under it.
   - **If an `ISS` already owns the cause:** record the `REG` there rather than minting a second issue.
   - **If the existing `ISS` is symptom-shaped:** extract its symptom as a `REG` under the same issue before generalizing it. Never retype or delete a durable `ISS` id.
   - **A `REG` always has exactly one current `ISS` parent.** Relinking changes that parent and appends to the `REG`'s `Link history` with a rationale; it never moves or rewrites the report.
   - **Blueprint-versus-code drift is a `TD`**, not a defect — author it from `td.md` with its removal trigger.
   - Preserve every reported regression **verbatim** in the `REG`'s `Reported behavior` section. Never edit, collapse, or delete it while fixing — it is the acceptance evidence the fix is validated against.
   - Refresh the `ISSUES.md` / `TECH_DEBT.md` index rows. Set **no** status here — `$status-update` owns it. Route the finding onward through `$reconcile`.
   - **Under `$orchestrate`, ids come from the brief.** If this slice needs one the brief did not provide, report the finding with its evidence and let the orchestrator allocate.
10. Commit atomically — stage explicit files only: the coverage document under `docs/validation/`, the authored `ISS`/`REG`/`TD` documents, the refreshed indexes, and nothing else. A scoped validation commit is required unless nothing versioned changed:
    - run `git status`;
    - commit the scoped validation result, citing the record ids it serves;
    - report commit SHA, commands run, evidence, authored ids, blockers, skipped scope, residual risk.
11. Hand back to `$implement` for rework, or forward to the orchestrator/delivery state. A failed gate is not cleared until the same full gate is rerun and passes.

## Delegated-slice rules

- Do not fix defects unless explicitly reassigned as a developer.
- Do not relax acceptance criteria or treat partial evidence as a pass.
- Do not perform merge or production deploy unless explicitly assigned.
- Do not revert unrelated parallel-agent work.
- Do not set status on any record.

## Template References

From the active runtime root's `templates/` directory:
- `iss.md`
- `reg.md`
- `td.md`

## Report format

- Status: `VALIDATED` or `NOT VALIDATED: <exact missing/failing gate>`.
- Evidence: commands run, result, relevant files/tests/artifacts, `AC`/`TRC` ids covered.
- Validation artifacts: the coverage document path and the rows it added or updated.
- Feedback: any `ISS`/`REG`/`TD` ids authored, with their document paths.
- Handoff: next edge, required rework if any, validation commit (required when versioned artifacts changed), blockers, residual risk.
