# SDLC lessons from Cabinet delivery stagnation

**Investigation date:** 2026-09-28  
**Consumer inspected:** `stobox-cabinet-v2` `latest` at `4e15cc267e2688824d4fd681efb7c8d149c41c39`  
**Policy inspected:** `package/policy/RULES.md` and `package/skills/orchestrate/SKILL.md` at `1c7f39a`  
**Disposition:** Analysis and proposals only. No instruction surface is changed by this report; a rule change routes through `/meta-learn` or an explicit owner instruction.

This is the methodology third of a split investigation: what an orchestrator driving sub-agents should learn from Cabinet's stall, **independent of any delivery engine**. The product diagnosis stays in `stobox-cabinet-v2` at `docs/analysis/2026-09-28-product-delivery-stagnation-root-causes-and-recovery-plan.md`. Engine-specific defects and cost readings live in `agent-foundry/factory` at `docs/analysis/2026-09-28-cabinet-delivery-stagnation-factory-engine-findings.md`.

## Diagnosis

**The process optimized for formally accountable fragments rather than a finished customer outcome.** Every lesson below is a way that happens under an orchestrator with sub-agents, whether or not an engine schedules them.

This is not a shortage of requirements, tests, agents or architectural detail. Adding more of those under the same process makes it worse.

## Evidence in brief

Readings at 2026-09-28, taken from the consumer; the Cabinet and Factory reports hold the full tables and reproduction commands.

- 369 WOs, 1,018 issues, 440 debt records, 303 accepted ADRs; 778 ISS + TD nonterminal, 357 of them categorized `docs` or `test`.
- 55.5% of tracked files are documentation, 15.7% product code.
- A bounded 11-day sample: 984 sub-agents, 207.5 agent-hours; validation stages took more time (73.2 h) than implementation (58.9 h); 37 of 93 records appeared in more than one run.

## 1. Failure modes

### A. Completion is defined below the level at which customers receive value

A foundational WO can close while the journey that consumes it stays unavailable. Horizontal decomposition — seams, models, producers, surfaces, placeholder markers, follow-up WOs — without a release boundary that requires the whole transaction to work lets activity and local correctness rise while usefulness barely moves.

**Lesson:** a slice's done condition names the user-visible behaviour it moves. A slice that cannot state one is an enabling slice, and it is scheduled only behind the journey that needs it.

### B. "Accounted for" drifted from "usable"

Cabinet accepted a design-parity rule under which an unbuilt datum is satisfied by a marker that draws nothing, checked by source-text inspection. A rule that also resolves ambiguity toward the larger surface then rewards more shell and more follow-up obligations.

**Lesson:** keep three verdicts distinct — inventory accounted for, surface faithful, journey operationally complete. Only the last two support a readiness claim. A structural check that proves the first is never reported as the second.

### C. A single-source-of-truth rule without a mechanism

The rules already say *fix at the source of truth* and *cite by id, never by copied text; `$context-compiler` hydrates full text on demand*. In Cabinet the criterion text existed twice, the copies disagreed, and hydration returned nothing while telling the caller to author the text. Three delivery attempts followed superseded prose.

**Lesson:** a retrieval path that fails, or returns a mutable copy, defeats the rule however often it is restated. Hydration fails closed — an empty population is a blocker, never an invitation to author. More reminders to consult authority repair nothing.

### D. Worktrees isolate files, not meaning

The rules isolate each lane's git tree, ports and stores. They do not isolate a shared contract, a shared index, or a generated projection of shared state rendered into a branch. Lanes then reconcile each other's facts, conflict on generated files, and confuse *current global state* with *the contract this branch implements*.

**Lesson:** a shared surface — schema, contract, runner, index — has **one integration owner**, and its changes serialize. Declared dependencies and exact file overlap are not enough to detect a shared-surface conflict; preflight for one before dispatch. Render shared indexes at the integration point, not in each lane.

### E. Recovery that re-reasons instead of resuming

Cabinet's sample shows fresh invocations of completed and killed work under one logical run, every repeat escalated to the strong tier, extra agents dispatched only to reconstruct a missing report, and polling done through agent tool calls.

The orchestrate skill's ladder — same-runtime resume, then worktree hand-over — is sound for a *dead agent*. It does not distinguish failure classes, and nothing stops an unchanged failure from retrying.

**Lesson:**

- Route by failure class. A transport, environment or report failure does not escalate the model tier; only a reasoning failure can justify one.
- A missing receipt — a commit hash, a report envelope — is read from git or the ledger, not reconstructed by a new agent.
- Waiting on a process is the harness's job, not an agent's poll loop.
- An unchanged failure stops, preserves its checkpoint and reports the blocker. It does not retry.
- Resume completed stages only when item, contract, head and inputs still match; never reuse validation across changed code.

### F. Formalism creates work recursively

Cabinet accumulated work to author missing blueprints, reconcile duplicated criterion tables, check figures copied into contracts, repair proof links, account for missing markers, and repair the machinery that validates those obligations. Some were real repairs. Together they form a loop:

> Missing behaviour → formal finding → new artifact → new consistency obligation → new failure → more artifact work.

A 9,074-line contracts document and process boilerplate repeated in every implementation plan raised retrieval and reconciliation cost without adding executable clarity.

**Lesson:** the remedy is fewer independently authored facts and fewer mandatory transformations, not shorter sentences. A finding whose only fix is another artifact is suspect until it names the behaviour it protects. Procedure lives once, in the skill, and never in each WO.

### G. Status and plan stopped forecasting

The live plan still carried a September 15 production deadline; 7 of 36 milestones declared a gate; most requirements read `Not Implemented` despite many closed WOs. The status system produced a large work inventory, not a release picture.

**Lesson:** a forecast comes from one representative slice completed under the current process — its measured integration and provider-validation time — never from summing story points or counting closed records.

## 2. Proposed methodology

### Default production loop

> Define one observable change → write failing behavioural tests → implement → independently verify → integrate → prove the released journey.

Keep responsibilities distinct without paying for a fresh, fully hydrated sub-agent at every administrative transition.

### Risk-based role separation

| Change | Treatment |
|---|---|
| Documentation or metadata | Focused consistency checks; no product E2E |
| Bounded low-risk behaviour | Test-first implementation; independent verifier |
| Auth, billing, storage, migrations, sensitive dependencies | Independent QA authoring, implementation, verification, targeted security review |
| Domain, cardinality or trust-boundary change | Architect review before implementation, plus the high-risk chain |

### Scope control

- Stop new starts outside the selected outcome; checkpoint and preserve existing WIP.
- A discovered improvement is not current-release scope unless it blocks the outcome.
- Start with **a WIP cap of two product slices plus one enabling process fix**; adjust from measured integration throughput, not from available agent slots.
- Never cut RLS or tenant isolation, credential boundaries, migration safety, human confirmation of extracted facts, recovery of paid operations, or entitlement verification.
- Do not remove dead-looking code or cancel records wholesale: a postponed capability may share infrastructure with the launch slice.

### Minimum artifact responsibility

| Artifact | Responsibility |
|---|---|
| Release definition | Customer, paid outcome, supported scope, exclusions, acceptance demonstration |
| Requirement | Intent plus one authoritative set of observable criteria |
| Design reference | Approved screens and states for the released journey |
| Context model | Domain invariants, ownership, lifecycle, external boundaries |
| ADR | One decision, reasons, rejected alternatives, consequences |
| Delivery item | Unique change, dependencies, touched surfaces, criteria, proof |
| Issue | Reproduction, current cause, impact, closure condition |
| Regression | Original immutable symptom and evidence |
| Generated index | Navigation or projection, never a second authoring surface |

### Steering metrics

- Complete user journeys proven at the shipping head.
- Elapsed time from slice start to integrated, verified behaviour.
- Agent cost and tokens per integrated slice.
- Repeated attempts with an unchanged failure cause.
- Time blocked on shared surfaces.
- Escaped defects and recovery success.

Never target closed-record count, ADR count, test count or documentation share.

## 3. Rule surfaces this bears on

Candidates for `/meta-learn`, listed so the evidence lands where the decision will be made. None is edited here.

| Surface | Clause | Tension |
|---|---|---|
| `RULES.md` — Planning, Implementation, and Scope | "never drop `$implement` → `$validate` → `$security-review` → `$status-update`" | Universal chain for every change; §2 proposes risk-based separation. Revising it is explicit, never a quiet skip. |
| `RULES.md` — Handoffs, Validation, and Delivery | "Do not call work validated/complete … until preview/release E2E …" | Correct, but defined per record; nothing requires a *journey*-level done condition (§1.A). |
| `RULES.md` — Artifact Propagation | `$context-compiler` hydrates full text on demand | States the mechanism, not its failure behaviour (§1.C). |
| `RULES.md` — Feedback Loops | Triage before minting `ISS`/`REG`/`TD` | Guards duplicates, not recursion; nothing asks what behaviour a finding protects (§1.F). |
| `orchestrate/SKILL.md` — recovery ladder | Rung 1 resume, Rung 2 worktree hand-over | No failure-class routing, no unchanged-failure stop, no receipt-from-ledger rule (§1.E). |
| `orchestrate/SKILL.md` — parallelization | Fan out every WO with no unmet dependency; a declared shared dependency is a sequencing barrier | The barrier fires only on dependencies someone declared. Nothing detects an undeclared shared surface before dispatch, names its integration owner, or keeps lanes from rendering shared indexes (§1.D). No WIP cap (§2). |
