---
name: cleanup
description: Clean up stale delivery worktrees, branches, and runtime stacks left by orchestration runs, and identify + triage unmerged commits or uncommitted stages before anything is removed. Use when asked to clean up or prune stale branches/worktrees, stop leaked worktree services or stores, or find and triage unmerged/uncommitted delivery work.
argument-hint: repo path, integration/merge target branch, or specific worktree/branch/record ids
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
context: fork
---

# /cleanup - Delivery Lane Cleanup

- Sweep the leftovers of orchestration runs — dedicated worktrees, `task/*` branches, and runtime stacks — removing only what is provably safe and triaging every worktree that still holds unmerged commits or uncommitted changes.

## Purpose

- `$orchestrate` creates one dedicated worktree (`.worktrees/WO-nnn`) on branch `task/WO-nnn` per delegated item and does NOT auto-merge; it merges green items forward, then tears their lanes down.
- Finished, abandoned, and crashed runs leave residue: merged worktrees not yet removed, branches with unmerged commits, dirty uncommitted trees, and runtime stacks still holding their shifted ports and `ORCHESTRATOR_WT` stores.
- `/cleanup` is the operational counterpart to orchestrate's *Lane teardown*: it inventories that residue, classifies each item, auto-removes the provably safe, and surfaces the rest for a decision — it never discards unmerged or uncommitted work on its own.

## Inputs

- `$ARGUMENTS`: optional repo path, the integration/merge target branch, or specific worktree/branch/record ids to scope the sweep.
- Live state (read-only first): `git worktree list`, `git branch`, each worktree's `.orchestrator.env` (`ORCHESTRATOR_WT` + `ORCHESTRATOR_SHIFT_INDEX`), each record's status row in its index (`WORKORDERS.md`, `ISSUES.md`, `TECH_DEBT.md`), and merge state against the integration target.
- The active repo `AGENTS.md` for the integration branch, PR base, and the isolated launch path's matching **stop path** (the repo owns which services and stores an `ORCHESTRATOR_WT` lane holds).

## Outputs

- A classification/triage table of worktrees, branches, and runtime stacks with each disposition.
- Automatic removal of provably safe leftovers (merged + clean + inactive).
- Approval-gated shutdown of leaked runtime stacks through the repo's own stop path, or a report of the ports/stores still held.
- Eager deletion of each removed worktree's central code-graph index (its in-worktree qmd `.qmd` goes with the dir).
- Approval-gated disposition of every unmerged / uncommitted / ambiguous item — never silent deletion.
- A report: what was removed, what was preserved and why, and which items need a merge or discard decision.

## Workflow

1. Resolve scope and the **integration target**. Take it from `$ARGUMENTS`; else infer the primary work branch that `task/*` items branched off, cross-checking the repo `AGENTS.md` integration branch and PR base. If the target is ambiguous, ask before classifying anything as merged.
2. Inventory (READ-ONLY — mutate nothing here):
   - `git -C <REPO> worktree list --porcelain` — every worktree; flag `.worktrees/*`.
   - `git -C <REPO> branch --list 'task/*'` and `git -C <REPO> branch --merged <target>`.
   - each record's status row in its index — is the item still active (`Open` / `Implementing` / `Validating` / `Blocked`) or finished (`Validated` / `Closed` / `Decommissioned`)?
   - each worktree's `.orchestrator.env` plus the repo's own status/stop path for that `ORCHESTRATOR_WT` — does the lane still hold services or stores? Ask the repo, never guess a port; the repo owns the mapping.
   - the active orchestration ledger, when one is in session, for lanes a live agent still owns.
3. Classify each worktree / branch / stack against the **Classification** matrix below (merge state, commits-ahead, dirty, record status, live-agent ownership). Detect dirty with `git -C <wt> status --porcelain`; unmerged commits with `git -C <wt> log --oneline <target>..HEAD`.
4. Triage the non-safe set. For UNMERGED-COMMITS and DIRTY, report the record id, its index status, the commit list (`log --oneline <target>..HEAD`), and a dirty summary (`diff --stat` + `status --porcelain`); recommend the route — merge-forward through the orchestrate merge gate, checkpoint the WIP (commit with explicit paths), or discard only when the item is superseded or `Closed`. Route any downstream finding the WIP reveals through `$reconcile`; never bury it by deleting the worktree.
5. Present the plan as a table (worktree · branch · record → state → action). Auto-run only SAFE-REMOVE. For every destructive action on a WIP-bearing or ambiguous item, get explicit approval (`AskUserQuestion`) — per item, or one batched confirm.
6. Execute approved actions with EXPLICIT paths only:
   - Stop a leaked stack before removing its worktree: run the repo's own stop path scoped to that `ORCHESTRATOR_WT`. Approval-gated and only for a lane no live agent owns — never a raw `kill`/`pkill`, never a port sweep, never another lane's live stack. If the repo has no stop path, report the lane's ports/stores instead and leave them running.
   - `git -C <REPO> worktree remove <path>` — let git refuse a dirty tree; never `--force` unless the user explicitly discards that tree's changes.
   - After removal, reap that path's central code-graph index (codebase-memory leaks one graph per dead worktree): find it by `root_path` in `codebase-memory-mcp cli list_projects '{}'`, then `codebase-memory-mcp cli delete_project '{"project":"<name>"}'`. The worktree's qmd `.qmd` is inside the dir and already gone with it — no separate step.
   - `git -C <REPO> branch -d <branch>` for merged branches; `-D` only after an explicit discard decision.
   - `git -C <REPO> worktree prune` to clear admin records for already-deleted dirs.
7. Report: removed (worktrees / branches), stacks stopped or still holding ports/stores, preserved-and-why, and pending merge/discard decisions. Leave blocked or replanned items' worktrees in place for the restart-in-worktree recovery flow.

## Classification

| State | Detection | Disposition |
| --- | --- | --- |
| ACTIVE | a live agent owns the lane per the session ledger, or the record is `Implementing`/`Validating` with recent commits | LEAVE untouched — a session is working it |
| SAFE-REMOVE | branch in `--merged <target>` AND worktree clean AND no live owner | auto: stop its stack, then `worktree remove` + `branch -d` |
| UNMERGED-COMMITS | commits in `<target>..HEAD`, worktree clean | TRIAGE: merge-forward or explicit discard; never auto-delete |
| DIRTY-UNCOMMITTED | `status --porcelain` non-empty | TRIAGE: checkpoint the WIP or hand to owner; NEVER force-remove |
| ABANDONED | no commits ahead, clean, no live owner, record not active in its index | propose remove (confirm) |
| LEAKED-STACK | `.orchestrator.env` lane still holding services/stores, no live owner | propose stop via the repo's stop path (confirm); report if it has none |
| ORPHAN-RECORD | a worktree admin record whose path no longer exists | `worktree prune`; report any stack that path left behind |
| FOREIGN | worktree/branch not orchestration-created (`.worktrees/*` / `task/*`) | LEAVE untouched unless the user names it |

- A squash- or rebase-merged branch shows as unmerged by ancestry, so it lands in UNMERGED-COMMITS (correct — a human confirms `-D`); only ancestry-merged branches (`--merged`) are ever SAFE-REMOVE.

## Safety & guardrails

- Preservation-first: never delete unmerged commits or uncommitted changes without explicit human approval — unmerged WIP is evidence, not garbage.
- Never `git worktree remove --force` a dirty tree; never `git branch -D` an unmerged branch without a discard decision. Prefer plain `remove` / `-d` so git itself refuses.
- Never touch a worktree/branch a live agent owns, or any non-orchestration worktree/branch you did not create, unless the user names it.
- Explicit paths only — never `rm -rf` a worktree directory (use `git worktree remove`); no globbed deletes.
- Never delete `.git/index.lock` or other lock/state files.
- Never terminate a process the current agent did not itself launch. A repo's own `ORCHESTRATOR_WT`-scoped stop path is the one sanctioned exception — approval-gated, on a lane no live agent owns; anything broader stays a report.
- A stalled lane is a pickup candidate FIRST (per orchestrate's death/hand-over ladder): only clean it once its worktree is merged, discarded, or confirmed empty.
- Also sweep the ordinary workspace residue this run created — temp files, logs, debug output, build artifacts — but never another agent's artifacts unless they block active scope and the owner or user approves.
