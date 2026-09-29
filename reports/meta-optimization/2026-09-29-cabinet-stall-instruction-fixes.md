# Instruction fixes: Cabinet delivery stagnation

**Date:** 2026-09-29
**Record:** `WO-183`
**Evidence:** `docs/analysis/2026-09-28-sdlc-lessons-from-cabinet-delivery-stagnation.md`. This review covers instructions only: the evidence comes from the Cabinet consumer's records and the sibling reports, and this memo re-reads no session transcript.
**Baseline:** `package/` at `1c7f39a`. Deployed `~/.claude` copies matched the source before the edits; the only pre-existing gap was `skills/qmd/references`, which is missing from the deployment.
**User decisions:** a risk-tiered delivery chain, no numeric WIP cap, one pass committed directly to `dev` with no PR.

## Failure modes

| Mode | What happened | Root | Fix surface |
|---|---|---|---|
| A | WOs closed while the journey stayed unavailable | No done condition in the WO contract | `templates/work-order.md`, `skills/planner`, `policy/RULES.md`, `skills/orchestrate` |
| B | Placeholder markers satisfied parity checks | Coverage has one verdict level | `policy/RULES.md`, `skills/validate`, `skills/status-update`, `agents/validator.md` |
| C | Hydration returned nothing and told the caller to author the text | No failure behaviour for hydration | `policy/RULES.md`, `skills/context-compiler`, `skills/implement`, `skills/orchestrate` |
| D | Lanes reconciled each other's facts and conflicted on generated files | Barrier only on declared dependencies; lanes render indexes | `skills/orchestrate`, `skills/implement` |
| E | Repeats escalated to strong, agents rebuilt reports, agents polled | Recovery ladder had no failure classes | `skills/orchestrate`, `policy/RULES.md` |
| F | Findings produced artifact obligations that produced more findings | Minting never asked what behaviour a finding protects; templates forced procedure into every plan | `skills/reconcile`, `skills/review`, `skills/validate`, `skills/security-review`, `templates/{iss,td,implementation-plan,work-order}.md` |
| G | Plan kept a stale deadline; status counted records | The rollup was backward-looking tallies | `skills/status-update`, `templates/plan.md`, `skills/orchestrate` (ledger metrics) |
| Chain | Validation cost more than implementation on docs-level work | One chain depth for every item | `policy/RULES.md`, `skills/{orchestrate,validate,security-review,implement}`, `workflows/SWE.md` |

## Instruction fixes

All targets are `package/**` source paths.

- **`policy/RULES.md`**
  - *Planning, Implementation, and Scope*: REPHRASE "never drop the chain" to a chain that runs for every item at its risk tier, and ADD the T0–T3 table. ADD the done-condition, enabling-sequencing and outcome-scope bullet (A, Chain).
  - *Handoffs, Validation, and Delivery*: REPHRASE the validated claim so it names the tier's gates and the tier. ADD the accounted / faithful / journey-complete verdicts (B).
  - *Artifact Propagation*: ADD "Hydration fails closed…" (C).
  - *Feedback Loops*: ADD the protected-behaviour clause to triage (F).
  - *Modes and Delegation*: ADD escalation only on a verified reasoning failure, and REPHRASE "recover it on the ladder" to recover by failure class with an unchanged-failure stop (E). ADD the T0 in-session exemption.
  - *Delivery State Machine* and *Stages*: REPHRASE both to point at the tier. *Quick Reference*: updated.
- **`skills/orchestrate/SKILL.md`**
  - ADD a *Risk tier* subsection.
  - ADD ledger fields: selected outcome, both tiers, failure signatures, slice time and agent count (G).
  - ADD scope control (A).
  - ADD shared-surface preflight, integration owner, and indexes rendered at integration (D).
  - ADD the hydration blocker at the pre-delegation gate (C).
  - REPHRASE recovery into a failure-class table, with an unchanged-failure stop, resume-don't-redo, and the harness doing the waiting (E).
  - ADD brief fields (tier, done condition, owned shared surfaces), index rows in the final report, and checklist lines.
- **`skills/context-compiler/SKILL.md`**: ADD the fail-closed rule, the `Status: READY | BLOCKED` bundle line, and the blocker handling in step 3 (C).
- **`skills/implement/SKILL.md`**: ADD stop-on-unresolved-criterion (C), test-first at T1+ (Chain), and no generated-index edits or edits to shared surfaces the lane doesn't own (D).
- **`skills/planner/SKILL.md` and templates**
  - ADD `Done When` and enabling sequencing (A), and journey-named Milestone gates (G).
  - ADD `Protects` to `iss.md` and `td.md` (F).
  - DROP the fixed Delegation Map, Execution Steps and unit/integration guidance boilerplate (F).
- **`skills/validate/SKILL.md`, `agents/validator.md`**: ADD per-row verdict levels (B), tier-scoped gates (Chain), the Done When check (A), and the `Protects` requirement for findings (F).
- **`skills/status-update/SKILL.md`**
  - REPHRASE `Implemented` to require `faithful` or better, with `accounted` capped at `Partial` (B).
  - ADD the release picture and a measured forecast basis, and drop unsupported deadlines (G).
- **`skills/reconcile/SKILL.md`**: ADD the protected-behaviour test to *Triage before minting* (F). `skills/review` and `skills/security-review` cite it.
- **`skills/security-review/SKILL.md`**: ADD review depth by tier; a finding at any depth promotes the item to full review (Chain).
- **`workflows/SWE.md`**: REPHRASE the three chain restatements to point at the tier. Fixed the contradiction in the review-gate note (Medium runs `/review`).

## Re-validation

The verdicts below come from reading the updated text; no orchestrated run exercised them. An independent validator pass on 2026-09-29 found ten issues. Those in scope were fixed in the follow-up commit: the T0 verdict path, the in-session carve-out in `orchestrate`, lanes returning index rows, the model-tier wording, `Protects` for `ISS`/`TD` only, and the README chain line.


| Mode | Now governed by | Verdict |
|---|---|---|
| A | `RULES.md` done-condition bullet; `work-order.md` `Done When`; planner checklist; `validate` step 4; `orchestrate` scope control | **Reduced + detected.** A WO without `Done When` fails the planner checklist. A behaviour-bearing WO cannot pass validation below `faithful`. |
| B | `RULES.md` three verdicts; `validate` verdict levels; `status-update` value meanings | **Reduced + detected.** A marker-only surface is capped at `accounted`/`Partial`, and the verdict level is visible on every coverage row. |
| C | `RULES.md` fail-closed hydration; `context-compiler` `BLOCKED`; `implement` step 2; `orchestrate` pre-delegation gate | **Prevented where the stage complies.** Four surfaces now block on the same condition. Enforcement is still agent compliance, since there is no hydration script to fail mechanically. |
| D | `orchestrate` preflight, integration owner, `$status-update` renders returned rows after each merge; `implement`/`validate`/`security-review` return index rows under `$orchestrate` | **Reduced.** The preflight is a judgment comparison of declared surfaces, so an undeclared surface can still slip through. |
| E | `orchestrate` failure-class table; `RULES.md` escalation and retry | **Reduced + detected.** Failure signatures in the ledger make an unchanged retry visible. |
| F | `RULES.md` and `reconcile` protected-behaviour triage; `Protects` fields; leaner templates | **Reduced.** Recursion can still occur through a finding that names a behaviour loosely. |
| G | `status-update` release picture; `plan.md` journey gates; `orchestrate` ledger metrics | **Reduced.** Nothing computes slice time or agent cost automatically; the ledger records it by hand. |
| Chain | `RULES.md` tier table; `orchestrate`, `implement`, `validate`, `security-review`, `SWE.md` (`status-update` has no tier-specific depth) | **Reduced.** A T0 item reaches `faithful` only through its consistency gates on the installed copy (`RULES.md`, verdicts). **Unresolved risk:** misclassifying an item down a tier. It is mitigated by resolve-up and by promotion on a finding, not eliminated. |

## Unresolved, outside this change

- `pre-commit run --all-files`: the shellcheck hook is red, with 18 findings in shell files this change does not touch, for example `package/install/runtimes.sh` SC2034. The trailing-whitespace and end-of-file hooks also fail repo-wide. That includes the hard line breaks (two trailing spaces) in the header of the Cabinet analysis doc, which are intentional Markdown and were left in place. The CI gate trio is green.
- `skills/validate` names the coverage path `docs/validation/WO-NNN.md` while requiring coverage keyed on `AC`/`TRC`, never on the WO number. This contradiction predates this change.
- The deployed Claude root is missing `skills/qmd/references`.
