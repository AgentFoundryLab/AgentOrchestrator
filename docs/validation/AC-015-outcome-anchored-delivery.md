# Coverage: AC-004.5, AC-011.5, AC-011.6, AC-012.8, AC-012.9, AC-015.1–AC-015.4 — outcome-anchored delivery

Date: 2026-09-29 · Serves `WO-183` · Risk tier: T0 (instruction text only) · Source head: `03181d0`

## Method

These criteria are instruction behaviour. Per `policy/RULES.md`, a T0 surface earns `faithful` when its consistency gates pass on the installed copy. Every run below was executed. Nothing here is carried forward from an earlier assessment.

```bash
bash install.sh --check
bash tests/package/vocabulary.sh
bash tests/install/smoke.sh
bash install.sh --global --claude --overwrite   # deploy to ~/.claude
diff -rq package/{skills,agents,templates} ~/.claude/{skills,agents,templates}; diff -q package/policy/RULES.md ~/.claude/policy/RULES.md
grep -rn "never drop\|never shortens\|fixed delivery chain\|same gates as" package docs/requirements docs/architecture AGENTS.md README.md
```

- An independent validator reviewed `git diff 1c7f39a..HEAD` read-only. Its in-scope findings were fixed in `03181d0`.
- No orchestrated delivery run has exercised these rules yet, so no row reaches `journey-complete`.

## Results

| Criterion | Governing text (installed copy) | Verdict level | Result |
|---|---|---|---|
| `AC-004.5` | `policy/RULES.md` tier table; `skills/{orchestrate,validate,security-review,implement}`; `workflows/SWE.md` | faithful | Pass |
| `AC-011.5` | `templates/work-order.md` `Done When`; `skills/planner` step 4 and checklist | faithful | Pass |
| `AC-011.6` | `policy/RULES.md` *Artifact Propagation*; `skills/context-compiler` `BLOCKED`; `skills/implement` step 2; `skills/orchestrate` pre-delegation gate | faithful | Pass |
| `AC-012.8` | `skills/orchestrate` failure-class table and steps 6–8; `policy/RULES.md` *Modes and Delegation* | faithful | Pass |
| `AC-012.9` | `skills/orchestrate` step 7 preflight, integration owner, and `$status-update` rendering; lane rules in `skills/{implement,validate,security-review}` | faithful | Pass |
| `AC-015.1` | `policy/RULES.md` enabling/outcome bullet; `skills/orchestrate` scope control; `skills/planner` step 5 | faithful | Pass |
| `AC-015.2` | `policy/RULES.md` three verdicts; `skills/validate` verdict levels; `agents/validator.md`; `skills/status-update` value meanings | faithful | Pass |
| `AC-015.3` | `policy/RULES.md` and `skills/reconcile` triage; `Protects` in `templates/{iss,td}.md`; `skills/{validate,review,security-review}` | faithful | Pass |
| `AC-015.4` | `skills/status-update` step 8 release picture; `templates/plan.md` journey gates | faithful | Pass |

## Gates

| Command | Result |
|---|---|
| `bash install.sh --check` | exit 0, no drift |
| `bash tests/package/vocabulary.sh` | 5/5 passed |
| `bash tests/install/smoke.sh` | 53/53 passed. One earlier run hung in an external `uvx … serena project create` call; the rerun passed. |
| Deployed-copy diff | identical except `skills/qmd/references`, a pre-existing gap outside this scope |
| Restatement sweep | no universal-chain restatement remains |
| `pre-commit run --all-files` | **failed.** `shellcheck` reports 18 findings in shell files this change does not touch (e.g. `package/install/runtimes.sh` SC2034), and the whitespace hooks fail on other untouched files. |

The red lint gate blocks a `validated` claim for `WO-183` until it is fixed or the user waives it.
