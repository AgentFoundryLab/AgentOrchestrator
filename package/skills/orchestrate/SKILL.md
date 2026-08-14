---
name: orchestrate
description: Coordinate work with persistent sub-agent delegation across spec, architecture, planning, implementation, validation, security, and status, or a chained subset. Use when the user asks to orchestrate, delegate, use sub-agents, split work across agents, or invokes $orchestrate.
argument-hint: project idea, goal, stage chain, task id, or feature scope
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Agent
  - SendMessage
  - TaskCreate
  - TaskUpdate
  - TaskList
  - AskUserQuestion
---

# $orchestrate - Orchestration Procedure

- The primary entry point for delegated multi-agent delivery. Owns mode persistence, workflow-depth selection, delegation requirements, handoff commits, parallel-agent worktree policy, and the delivery state machine.
- Loads global policy from the active runtime root's `policy/` directory (`PRINCIPLES.md`, `RULES.md`). Active repo `AGENTS.md` owns repo-specific commands, paths, validation gates, remotes, PR bases, and safety rules.

## Trigger boundary

- Use when the user invokes `$orchestrate` or asks to orchestrate, delegate, use sub-agents, split work across agents, or run delegated/parallel work.
- A plain record id, stage name, artifact path, or depth/thoroughness request does NOT start Orchestration Mode.
- Once triggered, it persists until session end or explicit user override; blockers, corrections, failed checks, and direct skill invocations do not end it.

**The orchestrator never edits product code, repo docs, tests, or status artifacts directly** for non-trivial work. It coordinates; sub-agents execute. Direct edits are allowed only for genuinely atomic, non-parallelizable glue, a security/credential boundary requiring primary-only handling, or when the user explicitly overrides delegation for that scope.

## Context Discipline

Lean context = clear signal. A cluttered orchestrator misses decision points, picks the wrong depth, and loses the thread.

**Read (high-level only):** `docs/development/ROADMAP.md`, `docs/development/WORKORDERS.md`, `docs/requirements/REQUIREMENTS.md`, sub-agent result summaries.

**Read before implementation delegation:** resolve the Work Order document and its implementation plan from `WORKORDERS.md`, then load only the narrowest authoritative section needed for the worker brief. Prefer the exact WO or plan anchor over a broader Plan document.

**Never read directly:** source files, full file contents, test files, logs. Delegate debugging, code review, and detailed analysis.

Keep orchestrator turns focused on: assess → delegate → checkpoint → proceed.

## Workflow Depths

Select the smallest chain that preserves traceability and validation. The delivery chain that runs at every depth is defined in the `RULES.md` stage map; the depth below selects only which planning stages precede it.

| Depth | Chain | Use when |
|---|---|---|
| **Full** | `$onboard` → `$spec` → `$architect` → `$planner` → `$review` → delivery | New product, complex system, multiple components, unclear requirements |
| **Medium** | `$spec` → `$planner` → `$review` → delivery | New feature, moderate complexity, clear scope |
| **Light** | `$planner` → delivery | Simple change, clear task |
| **Direct-fix** | delivery only, against an existing `ISS`/`TD` | Diagnosed, bounded defect with no new planning need |

The direct-fix path drops only the planning ceremony — never the scoped commit, focused validation, or status record. Mint a `WO` and run a fuller chain when the fix needs decomposition or touches a requirement, blueprint, domain/data model, or security/trust boundary; route those through `$reconcile`.

### Complexity assessment

| Factor | Score |
|--------|-------|
| New system/product | +3 |
| Multiple components | +2 |
| Integration needed | +2 |
| New API | +1 |
| UI changes | +1 |
| Simple fix | -2 |
| Documentation only | -3 |

Score >= 4 → Full; 1-3 → Medium; <= 0 → Light. Confirm the proposed depth with `AskUserQuestion` before starting.

## Procedure

1. Read the global policy, this skill, and the relevant stage skills. Read the active repo `AGENTS.md`.
2. Resolve the active contract from the user request and repo artifacts. Assess complexity, propose a depth, and confirm it.
3. Start/update the **orchestration ledger**: mode state + active contract; stage chain + next gate; sub-agent id/name, owned slice/files, lane resources (worktree, branch, runtime stack up/down), expected output, status; handoff commits, validation state, blockers, integration decisions.
4. Split critical-path from independent slices; mark delegation-owned slices. Read each Work Order's `dependsOn` in `WORKORDERS.md` to separate dependency-ordered from parallelizable work.
5. Delegate independent slices with disjoint ownership. For non-trivial implementation/validation/planning/status work, use sub-agents.
6. Always delegate into an isolated worktree (see *Lane provisioning*). Every code-editing sub-agent owns one worktree; concurrent agents never share one.
7. Parallelize a whole Phase or Milestone: enumerate its Work Orders from `WORKORDERS.md` by `Phase`/`Milestone`, derive the graph from `dependsOn`, and fan out every WO with no unmet dependency, one worktree each. Run dependents only after their blockers land. A shared dependency — schema, contract, or interface touched by multiple Work Orders — is a sequencing barrier, not a parallel slice. A Milestone is a coordination gate, never a code lane.
8. Stale/busy/excessive open agents are not a direct-execution excuse. Close, reuse, or retry supported agents first; if delegation capacity is still unavailable, report a delegation blocker.
9. On user design rejection, "start over", or "not accepted path", mark superseded plans/outputs rejected in the ledger, stop building on scratch changes, and restart from committed source-of-truth artifacts.
10. Integrate sub-agent outputs (merge each worktree back) without reverting unrelated parallel work, then tear the lane down (see *Lane teardown*).
11. Route each handoff through the atomic commit contract and the active repo's git rules.
12. Continue through the delivery state machine using the active repo's validation, PR, preview, status, and deployment rules.

### Pre-delegation context gate

Before delegating implementation or validation work:
1. Identify the candidate Work Order in `WORKORDERS.md`.
2. Open its document and, when present, its implementation plan.
3. Load only the narrowest authoritative source needed.
4. Build a minimal worker brief from that source, including the ids the slice may use.
5. Delegate.

If the Work Order is complex and has no discoverable implementation plan, stop and report incomplete execution context rather than delegating from a weak index row.

## Model calibration

Three tiers, selected per item from its risk classification:

| Tier | Selected by |
|---|---|
| **strong** | `WO` at `Complexity: High` or `Priority: P0`, or an `ISS`/`TD` at `Critical`/`High` severity |
| **cheap** | explicit `Complexity: Medium`/`Low` or `P1`/`P2`, or `Medium`/`Low` severity |
| **cheapest** | trivial mechanical work with no judgment call — a rename sweep, a formatting pass, a mechanical id substitution |

Unset or unclassified resolves **up** to strong, never down. Classify first; where it stays ambiguous, use strong.

### Per-harness bindings

Verified against each runtime's own configuration. **Never guess a model id** — an instruction file asserting a model that does not exist fails at dispatch.

| Tier | Claude | Codex | Kimi |
|---|---|---|---|
| strong | `opus` | `gpt-5.6-sol` | `kimi-code/k3` |
| cheap | `sonnet` | `gpt-5.6-terra` | `kimi-code/kimi-for-coding` |
| cheapest | `haiku` | `gpt-5.6-luna` | → cheap |

- **An unbound cheapest cell resolves DOWN to that harness's cheap tier, never up to strong.** Cheapest-tier work is trivial by definition and never earns the expensive model. Kimi is the only harness with no cheapest model — its cheapest work runs `kimi-code/kimi-for-coding`.
- A harness with no bindings recorded at all runs the **strong** tier until one is. Record a binding here only after verifying the id in that runtime's own config (`~/.codex/config.toml`, `~/.kimi-code/config.toml`, and so on).
- Retain the harness's configured reasoning effort; the tier selects the model, not the effort.
- Pass the tier explicitly at every dispatch. A spawn given none inherits the session default rather than the item's classification, so cheap work quietly buys the expensive tier and the ledger holds no tier decision to review. Calibrate per item, not per phase, and preserve the selected tier on resume.

## Id allocation — the orchestrator is the sole allocator

Delegated agents run in parallel worktrees against the same record index. If each minted its own id, two lanes reading "next unused is 121" both take it, and the collision is permanent because ids are never recycled.

- **Only the orchestrator (in Orchestration Mode) or the primary session (in Solo Mode) allocates a record id.** It reads the index, takes the next unused number, and writes the row before dispatch.
- **Every delegated brief carries the ids the slice may use.** A sub-agent never mints one.
- A sub-agent that believes it needs a record the brief did not give it **returns a blocker naming what it needs** — it does not allocate and proceed. The orchestrator mints it and either re-dispatches or hands it to the next slice.
- Allocate immediately before dispatch, not at planning time, so the number reflects the index as it actually stands when the lane starts.
- A crashed or killed lane is an unknown-state event, not a retryable no-op: before re-dispatching, read the index for rows the dead attempt may already have written, then brief the replacement to reuse those ids and mint nothing.
- Record every allocation in the ledger alongside the lane that owns it, so a lost brief is recoverable from the ledger rather than by re-deriving from the index.

## Lane provisioning: worktree and runtime isolation

- Create one dedicated worktree per delegated item at `.worktrees/WO-nnn` on branch `task/WO-nnn` (or `fix/ISS-nnn` for a direct-fix lane), unless the active repo `AGENTS.md` specifies otherwise. **The branch and worktree names carry the record id** — that naming is what makes lane ownership recoverable from `git worktree list` alone after a crash, a compaction, or an orchestrator restart, so never improvise a topic suffix.
- A fresh worktree checks out tracked files only. Run that repository's own documented install/bootstrap command inside it (from its `AGENTS.md`/README — never a guessed package manager). A worktree whose gates cannot run is a blocker, not a lane.
- Worktree setup fails closed: an omitted, non-absolute, wrong-repository, or wrong-branch path blocks the item. There is no fallback to the primary tree.
- **Runtime isolation, not just git.** Any lane that boots the app or its stores for local or preview E2E must shift every service port and namespace every ephemeral store (DB, schema, cache, queue) so parallel lanes never contend on ports or data.
  - The orchestrator owns only the allocation: at worktree setup, write the lane a gitignored `.orchestrator.env` carrying `ORCHESTRATOR_WT` (the record id, a stable naming prefix) and `ORCHESTRATOR_SHIFT_INDEX` (a small integer, unique across the concurrent set so indices never collide). It fixes no ports, DB names, or ranges.
  - The active repo owns the mechanism: its launch path sources `.orchestrator.env`, shifts each of its own service ports by `ORCHESTRATOR_SHIFT_INDEX`, and prefixes each ephemeral store with `ORCHESTRATOR_WT`, creating/dropping them per run. It owns the matching stop path, since only the repo knows its process/DB/cache topology.
  - Example: with `ORCHESTRATOR_WT=WO-042`, `ORCHESTRATOR_SHIFT_INDEX=7`, a repo might bind web `3000+7` / api `4000+7`, use Postgres schema `app_WO_042`, and prefix Redis keys `WO-042:`.
  - Boot a lane only through that `.orchestrator.env`-aware path, never a vendor's or framework's own start command — `RULES.md` carries the rule and why it corrupts a neighbour's lane.

## Lane teardown: stack, worktree, branch

- **A lane's two resources die at different times.** The runtime stack holds no work: the agent that booted it stops it through the repo's stop path before returning, pass or fail. The worktree and branch hold WIP: they survive until that lane's merge lands.
- **Stack-down gate at PR-ready:** each returning agent reports its stack down or names the ports/stores it left live; record that per lane in the ledger. Before a PR is opened for merge, close every live stack in its scope — hand each back to its own agent, or run that repo's stop path for a lane whose agent is gone. Never kill another lane's processes by hand, and never terminate a process this session did not launch.
- On integration: merge each green item's branch forward in dependency/wave order — a dependent's branch only **after** its blockers' branches land. A merge conflict on a shared surface is itself a sequencing barrier; resolve in order, do not parallelize.
- Holding for user approval (default): stage the green branches as a stack of dependent PRs so reviewers see the dependency chain, then merge after approval. Use the `gh-stack` skill for this when it is installed in the runtime; otherwise open the PRs in dependency order and state the chain in each PR body. Direct orchestrator merge-forward is allowed only when the user has authorized it for that scope.
- **Worktree cleanup happens AFTER that lane's merge lands** — never before (the WIP would be lost), never batched to the end of the wave. Both routes trigger it: a local merge-forward into the integration branch, or a merged PR. Remove the merged worktree and delete its branch, via a teardown sub-agent or directly:
  > Worktree teardown for `WO-nnn`. Its branch `task/WO-nnn` has been MERGED into `<integrationBranch>`. Confirm its runtime stack is down (repo stop path with `ORCHESTRATOR_WT=WO-nnn`); report any live port or store instead of killing processes. Run `git -C <REPO> worktree remove <worktree>` then `git -C <REPO> branch -d task/WO-nnn`. If the worktree has uncommitted changes, STOP and report — do NOT force-remove. Make no other changes and no commits.
- Blocked or replanned items leave their worktrees in place for the restart-in-worktree recovery flow until resolved, then merge or discard per outcome. Their stacks still come down — recovery reboots one, it does not inherit one.
- Finalization sweep: after the merges land and per-item worktrees are torn down, run `$cleanup` to prune residual merged worktrees and delivery branches, and to triage leftovers from crashed or abandoned runs (unmerged commits, dirty trees, leaked stacks). It removes only the provably safe and never discards unmerged/uncommitted work without approval.
- The run does not close while any worktree, branch, or stack it created is outstanding. Reconcile the ledger's lane list against `git worktree list` and `git branch --list 'task/*' 'fix/*'` at closeout, and name every leftover it deliberately leaves plus why.

## Sub-agent brief contract

Every delegated brief must be self-contained and include:
- repo path, the dedicated isolated worktree/branch the agent owns, and a warning that other agents may edit unrelated files in their own worktrees;
- instruction files to read: the global policy in the active runtime root's `policy/` directory, the active repo `AGENTS.md`, and the relevant skill/procedure;
- exact objective, stage, inputs, owned files/surfaces, exclusions, dependency boundaries;
- expected validation for the slice and whether the sub-agent may commit;
- checkpoint discipline (see below): commit + status note at each meaningful increment, and — when context runs low — checkpoint WIP first with a message naming done vs remaining;
- stack discipline: if the slice boots the app or its stores, start via the repo's isolated launch path — never a vendor's own start command — and stop it through that repo's stop path before returning; never leave a lane's services or stores running, and never stop another lane's;
- required final response: changed files/artifacts, checks run, last checkpoint commit SHA, done vs remaining, runtime stack down (or the ports/stores left live), blockers, skipped scope, residual risk.

Code-editing workers also: do not revert or overwrite others' changes; adapt to concurrent edits; stage/commit/push/PR only if explicitly assigned.

**Do not push a message into a delegated agent mid-task.** An injected coordinator message — a reply to the agent's own question, or an unprompted correction — can fork that agent's conversation into two branches sampled concurrently that share one id, one brief, and one worktree; both then edit and commit, and the lane reports files and commits it cannot account for. Send scope corrections between slices, or re-dispatch the slice.

## Checkpointing and context-limit recovery

- Sub-agents run with compaction off, so an agent can die mid-task when it exhausts context. Treat that as a recoverable failure, never a completion.
- Brief every sub-agent to checkpoint regularly. A checkpoint = durable proof of progress: a scoped commit of work so far PLUS a status note for the slice. Workers must:
  - checkpoint at each meaningful increment, not one big-bang at the end;
  - watch their own context budget and, when the limit approaches, checkpoint WIP first — commit what exists with a message naming completed vs remaining — so a successor can resume; never burn the last budget on more edits;
  - name the last checkpoint commit and the done/remaining split in the final report.
- Orchestrator recovery when an agent dies, stalls, or hits a session/runtime limit:
  1. Do NOT assume the slice is complete. The only evidence of progress is an explicit checkpoint (commit + status note); silence or a truncated final message means incomplete.
  2. Recover the lane binding: the ledger names the agent's worktree and branch, and `git worktree list` plus `git branch --list 'task/*' 'fix/*'` re-derives it independently when the ledger is lost.
  3. **Rung 1 — same-runtime session-resume (fast path):** if the session is still reachable in this runtime, resume it via the runtime's own primitive, briefed to reconcile against the objective and finish.
  4. **Rung 2 — worktree hand-over (universal):** otherwise — a different runtime, a context-dead session, or no session-resume — dispatch a fresh agent into the SAME worktree. Brief it to inventory BOTH the committed checkpoint (`git log`/`git show`) AND uncommitted dirty state (`git status`/`git diff`), verify that partial work for correctness rather than resuming blindly, then finish and checkpoint.
  5. Repeat until an explicit final checkpoint confirms the slice complete and validated. Only then integrate.
- Record each death, hand-over, and resume point in the ledger. A session-limit death is not a delegation blocker on its own — try same-runtime resume, then worktree hand-over, before ever reporting one.

## Stage outputs

- **Business Analyst** — assigned requirements slice only; return artifacts changed, open questions, blockers, residual risk.
- **Architect** — assigned architecture slice only; return artifacts changed, decisions made, blockers, residual risk.
- **Planner** — assigned planning slice only; return Plan / Work Order / implementation-plan changes, sequencing assumptions, blockers, residual risk.
- **Developer** — assigned implementation slice only; return changed files, focused checks, handoff commit if assigned, runtime stack state, blockers, residual risk.
- **Validator** — assigned verification slice only; do not fix defects unless reassigned as developer; return pass/fail evidence, commands, the validation report path, handoff commit if assigned, runtime stack state, blockers, residual risk.
- **Security** — assigned security gate only; return verdict (PASS/FAIL/FINDINGS), findings with attack paths, issue ids authored, blockers.
- **Tech Writer** — assigned review or documentation slice only; return findings or docs changed, blocking issues raised, residual risk.

## Decision points

Consult the user with `AskUserQuestion` at these points:
1. **Workflow selection** — confirm the depth is appropriate.
2. **Scope changes** — requirements materially different from expected.
3. **Trade-offs** — design decisions with significant impact.
4. **Blockers** — unable to proceed.
5. **Phase completion** — before major transitions (architecture → implement).
6. **Review findings** — after `$review`, if blocking issues found; route back to the owning agent before proceeding to `$implement`.
7. **Destructive or outward-facing actions** — production deploy, force update, discarding unmerged work.

## Checkpoint between phases

After each major phase, verify:
- [ ] Expected artifacts were produced (not just "agent returned")
- [ ] No pending question from the sub-agent
- [ ] No new blocking `ISS`/`TD` records from this phase
- [ ] User confirmed if the phase has significant outputs

## Closeout

- Integrate all completed sub-agent results, or record in the ledger why a result was rejected.
- Record delegation blockers explicitly; do not convert a delegation failure into unbounded primary edits.
- A slice is complete only when an explicit checkpoint (commit + status note) proves it; restart a context-limit-killed agent in its worktree rather than assuming the work landed.
- Reclaim every lane: stacks down at PR-ready, worktrees and branches gone as each lane's merge lands, `$cleanup` sweep last. Report any lane left standing and why.
- Do not claim completion without the active repo's required validation state.
- If any required edge remains blocked or unrun, report `NOT VALIDATED` with the exact gate and keep Orchestration Mode active unless the user ends it.

## Validation Checklist

- [ ] Workflow depth matches complexity and the user confirmed it
- [ ] Each phase produced expected artifacts (not just "agent returned")
- [ ] Artifacts flow correctly between phases; upstream conflicts routed through `$reconcile`
- [ ] Every non-trivial slice was delegated, each into its own isolated worktree
- [ ] Model tier was passed explicitly at every dispatch
- [ ] `$review` completed between `$planner` and `$implement` on Full/Medium depth; blocking issues resolved
- [ ] Decision points consulted the user appropriately
- [ ] Context stayed lean (no code/detail clutter in the orchestrator)
- [ ] Ledger is current: lanes, commits, validation state, blockers, integration decisions
- [ ] Every lane reclaimed — stacks down, worktrees and branches removed, or named with a reason
