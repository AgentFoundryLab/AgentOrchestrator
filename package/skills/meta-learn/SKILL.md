---
name: meta-learn
description: >-
  Analyze an agent session after failures, inefficiencies, instruction drift,
  orchestration breakdowns, validation misses, or context problems. Inspect
  current and sub-agent session logs (Claude Code or Codex — auto-detected),
  active global/project/agent/skill rules, identify failure modes and
  conflicting/weak/ambiguous instructions, plan rule optimizations,
  re-validate failure modes against updated rules, and git-version allowed
  instruction surfaces only.
argument-hint: optional focus area, session id, or failure description
context: inline
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
---

# Meta-Learn

Post-session learning and rule improvement. An analysis-and-instruction-optimization workflow, not product implementation.

This skill owns the full loop that observation, error capture, and proposal used to split between: it reads what actually happened from session transcripts, classifies the failure modes, proposes instruction changes with rationale, applies them only on request, and then re-validates each original failure mode against the updated rules.

## Runs inline — never as a spawned sub-agent

`context: inline`. Run this skill in the session that is under analysis, and never delegate it into a
child agent. Three reasons, each independently sufficient:

- **It edits instruction surfaces.** Rules files, agent profiles, and skills. A delivery lane is
  forbidden from touching those (`RULES.md`, *Source of Truth and Priority*) — this skill is one of
  the two sanctioned exceptions, and that exception belongs to the session holding the user's
  approval, not to a child spawned by a delivery lane.
- **A child cannot see the graph it is meant to analyze.** Its own transcript is a sibling of the
  agents under review, and it adds a node to the very graph it is reporting on.
- **Approval is interactive.** The patch plan needs `AskUserQuestion` before anything is applied. A
  sub-agent that asks gets its conversation forked, not answered.

When a sub-agent hits something learning-worthy, it **reports the signal in its final message** —
failure mode, where it showed, which instruction allowed it. The parent session runs `$meta-learn`
afterwards, with the full graph and the user present.

## Portability

This skill and `scripts/session_graph.py` work across both Claude Code and Codex without favoring either — every path/mechanism below is listed in pairs. AgentOrchestrator can deploy to several runtime roots on one machine, but they are never reconciled live against each other — only one runtime is active in any given session. Detect and use whichever runtime's surfaces exist for *this* session rather than hardcoding to one; when a machine has several runtimes' surfaces present from past use, inspect the one relevant to the failure actually being diagnosed, not all of them by default.

## Scope

Meta-learn may inspect:

- current and related agent session JSONL files:
  - Claude Code: `~/.claude/projects/<cwd-with-slashes-as-hyphens>/` — root sessions as `<sessionId>.jsonl`; sub-agent transcripts nested at `<sessionId>/subagents/agent-<agentId>.jsonl`.
  - Codex: `$CODEX_HOME/sessions` or `~/.codex/sessions` (flat dir, recursive).
- sub-agent linkage:
  - Claude Code: directory nesting (a sub-agent transcript's parent session id is its enclosing `subagents/` directory's parent-dir name, not a field inside the JSON); the sub-agent's role/type is its `attributionAgent` field when present.
  - Codex: `session_meta.payload.source.subagent.thread_spawn.parent_thread_id`.
- active global policy when present and runtime-verified: `<runtime-root>/policy/PRINCIPLES.md` and `RULES.md` for each installed runtime root (`~/.claude`, `~/.agents`, `~/.gemini`, `~/.config/opencode`, `~/.qwen`), plus that root's context doc (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.agents/AGENTS.md`).
- active global agents/skills when present and runtime-discovered: `<runtime-root>/{agents,skills}`.
- active project rules and project skills/agents when present: `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.agents/`, `.gemini/`, `.opencode/`, `.qwen/`, `docs/policy/` — only whichever actually exist in the repo.
- the orchestrator's own session and hook logs under `logs/` when present.
- git history/diffs for instruction surfaces.

Never commit or copy raw logs, sessions, cache, memories, shell snapshots, or plugin cache into a repo. Treat them as read-only evidence.

## Workflow

1. **Back up first**
   - Before editing global policy/skills/agents, copy the affected files to an excluded backup under the owning root, e.g. `~/.claude/backups/<UTC_TIMESTAMP>/`.
   - Before editing project rules/skills/agents, rely on git diff and commit history; do not copy repo files into logs/cache.

2. **Map the session graph**
   - Use `scripts/session_graph.py` (auto-detects the Claude Code vs Codex layout per file; pass `--runtime` to force one, `--sessions-dir` to point at an arbitrary root, `--project-cwd` to steer the default Claude Code projects-dir lookup) or equivalent JSONL inspection before drawing session-level conclusions, unless the user explicitly asks for instruction-only review.
   - **Start with `--self`.** It reads the runtime's own `CLAUDE_CODE_SESSION_ID` and resolves the root with no guessing. Analyzing a different session takes `--session <id>`; both print their provenance. Fall back to the mtime default only when neither is available, and report the run as heuristic when you do — the default picks the newest *root* session in scope, which is whatever was touched most recently, not necessarily the one that failed.
   - Both `--self` and `--session` locate the transcripts by scanning every projects dir for the id, so they work from any cwd. This matters in a worktree: a sub-agent running in `<repo>/.worktrees/<id>` still logs under the **parent's** encoded-cwd directory, so a cwd-derived lookup finds nothing there. Workflow-tool run journals are the mirror case — they land under the worktree's own encoded dir, keyed by the parent session id.
   - Identify the active/root session and all sub-agent sessions by parent linkage (directory nesting for Claude Code, thread id for Codex).
   - Summarize timeline, user corrections, tool failures, delegation attempts, commits, validation runs, mode changes, and reported blockers.
   - Redact secrets; do not paste long raw log excerpts.
   - **Deploy-drift check** — this skill can also run after the fact, in a session separate from whichever one caused a hand-edit. There is no manifest; compare the deployed copy against its source directly:
     - `diff -r package/skills ~/.claude/skills` and `diff -r package/agents ~/.claude/agents` from the AgentOrchestrator repo. The Claude root is the native format and receives no frontmatter transform, so a difference there is a real edit.
     - Other runtime roots (`~/.agents`, `~/.gemini`, `~/.config/opencode`, `~/.qwen`) legitimately differ: the installer strips `argument-hint`/`user-invocable`/`context`/`agent` from skills and `disallowedTools`/`skills`/`hooks` from agents, and maps tool names. Compare bodies below the frontmatter there, not whole files.
     - `install.sh --check` does NOT do this — it verifies the package layout and registry declarations only. `tests/install/smoke.sh` is the post-install conformance test.
     For each drifted path, compare its `mtime` against session timestamps/cwd from this same `session_graph.py` run, ranking candidate causal sessions by closest-preceding mtime — a hand-edit may not appear as a logged event at all, and only nearby transcript content explains *why*. Read the top candidate session(s) for the actual reasoning before asserting causation; mark `PLAUSIBLE, unverified` if nothing explanatory turns up.

3. **Classify failure modes**
   - Delegation/orchestration: token delegation, mode loss, missing ledger, wrong split, sub-agent misuse.
   - Delivery/validation: skipped gate, failed full gate not rerun, missing preview/status, premature completion claim.
   - Git/worktree: non-atomic commit, unrelated changes staged, active-scope conflict mishandled.
   - Context: overloaded prompt, missing artifact, stale status, wrong source-of-truth layer, progressive-discovery miss.
   - Tool/runtime: unavailable tool, invalid spawn shape, flaky provider, missing credentials/env.
   - Communication: hidden uncertainty, incomplete blocker, answer-vs-edit mistake.
   - Treat these as a generative naming scheme, not a closed list — name the shape of what actually happened; mint a new mode when none of the above fits.

4. **Analyze active rules**
   - Read only relevant sections first, then expand as needed.
   - Compare global policy, project rules, agent profiles, and skill instructions for conflicts, weak wording, duplicated source-of-truth, ambiguous lifecycle rules, and misplaced repo-specific policy.
   - Decide correct placement: global `policy/RULES.md`, global `policy/PRINCIPLES.md`, project `AGENTS.md` / `docs/policy/`, a global skill/agent, or a project skill/agent.
   - Note whether a rule is stated for one runtime only when the skill/agent file deploys to several — that asymmetry is itself a finding.

5. **Plan rule optimization**
   - Produce a concise patch plan with: problem, evidence, target file, exact rule intent, expected failure-mode prevention.
   - Prefer strengthening source-of-truth placement over duplicating rules.
   - Name the target surface by who can violate the rule: the always-loaded global policy holds what any agent can violate (honesty, traceability, safety, delegation); a rule only one stage can act on belongs in that stage's skill; a role or tool boundary belongs in the agent profile. A one-stage rule in the global policy pays rent in every session and fires in none.
   - Check the owning skill before proposing a policy clause — one that restates a section the skill already owns is redundant on arrival, and the two drift apart the moment either changes.
   - Never encode a workaround in an instruction surface: fix the tooling defect at its source, or raise the issue row. A rule telling future agents to avoid a broken path outlives the defect, and the surface then asserts behavior nothing re-derives.
   - Preserve high-signal existing rules; condense redundancy and generic prose.

6. **Apply only when requested**
   - Present the plan and get explicit user approval before applying anything. Observation and proposal are safe; application is not.
   - Edit only allowed instruction surfaces: a runtime root's `policy/`, `agents/`, `skills/`, or context doc; project `AGENTS.md`, `CLAUDE.md`, `docs/policy/`, `.claude/**`, `.agents/**`, `.gemini/**`, `.opencode/**`, `.qwen/**` when those are active configured instruction surfaces.
   - **Deployed-copy carve-out:** a surface installed by AgentOrchestrator's `install.sh` is a *deployed copy* — editing it directly is silently overwritten on the next install. Fix the source in the orchestrator repo's `package/{policy,agents,skills}/**` instead, then reinstall and re-run the diff above to confirm the fix reached the deployment. This carve-out does not remove meta-learn's ability to edit a global rule that is *not* orchestrator-managed (personal global rules, one-off agent/skill files, unrelated project instructions) — that direct-edit path stays as-is.
   - Do not edit product code, docs, logs, sessions, cache, memory, lockfiles, or generated artifacts unless the user explicitly requests broader remediation.

7. **Re-validate against failures**
   - Re-run the session-graph/rule analysis after edits.
   - For each original failure mode, state whether the updated rules now prevent, reduce, detect, or still miss it.
   - If a rule remains ambiguous, report it as unresolved instead of claiming success.

8. **Git-version instruction changes**
   - Global config: ensure each active global root is a git repo tracking only its context doc, `policy/**`, `agents/**`, and `skills/**`; exclude logs/sessions/cache/memories/plugins/tmp/backups/shell snapshots/runtime state. (`~/.claude` is commonly already a git repo — check before initializing.)
   - Orchestrator source: commit the `package/**` change in the orchestrator repo.
   - Project config: commit only the project instruction surfaces that changed.
   - Before every commit: `git status`, inspect staged/unstaged files, stage explicit allowed paths, commit only the scoped meta-learn change.

## Output — durable memos

Write the durable findings as memos so they outlive the session. Verify today's date; pick a short slug for the session/topic. Only write the file whose bucket has at least one finding.

### 1. `reports/analysis/<date>-<slug>-repo-failure-modes.md` — active repo
- Table: `Mode | Where it showed | Category | Tracked | Status` — `Tracked` MUST be a real `WO`/`ISS`/`TD` id from `docs/development/`, never hand-invented.
- Fixes section: one bullet per tracked id.
- Delivery note: landed vs in-flight vs unimplemented.

### 2. `reports/meta-optimization/<date>-<slug>-instruction-fixes.md` — instruction surfaces
- Table: `Mode | What happened | Root | Fix surface`.
- Instruction/agent fixes section: exact file target, REPHRASE/ADD/DROP verb, precise wording change, and which failure mode it prevents.
- When the fix targets an orchestrator-managed surface, name the `package/**` source path, not the deployed copy.

The in-chat "Report format" below stays the session-graph/failure-mode summary shown to the user in every run; these memos are the additional durable artifacts.

## Global root relocation gate

- Keep each installed runtime root separate and active unless relocation is explicitly requested and verified.
- Before moving a context doc, `policy/**`, `agents/**`, or `skills/**` between roots, produce a verification matrix proving current auto-load/discovery for each target surface under its actual runtime. Verification for `skills/**` does not prove the context doc or `agents/**`.
- If any surface is unverified, do not move it; keep the existing verified source of truth.

## Global git setup pattern

If a global root is not already a git repo and the user wants global rules versioned, initialize it with a deny-by-default exclude and stage only existing allowed instruction surfaces:

```bash
root=~/.claude   # or ~/.agents, ~/.gemini, ~/.opencode, ~/.qwen
cd "$root"
git init
cat > .git/info/exclude <<'EXCLUDE'
*
!/AGENTS.md
!/CLAUDE.md
!/policy/
!/policy/**
!/agents/
!/agents/**
!/skills/
!/skills/**
!/templates/
!/templates/**
EXCLUDE
git add -- AGENTS.md CLAUDE.md policy agents skills templates 2>/dev/null || true
git status --short
git commit -m "docs: version global instruction surfaces"
```

Do not track `sessions/`, `projects/`, `log/`, `logs/`, `cache/`, `memories/`, `plugins/`, `tmp/`, `.tmp/`, `backups/`, `.backup/`, `shell_snapshots/`, lockfiles, or runtime state unless explicitly requested.

## Report format

```md
## Session graph
- Root session:
- Sub-agents:
- Evidence inspected:

## Failure modes
- <mode>: evidence, cause, impact

## Instruction findings
- <file/section>: conflict/weakness/ambiguity, recommended placement

## Optimization plan or changes
- <change>: target, rationale, validation expectation

## Re-validation
- <original failure>: prevented/reduced/detected/still open

## Versioning
- Global commit:
- Orchestrator `package/**` commit:
- Project commit:
- Excluded evidence surfaces:

## Memos written
- reports/analysis/ repo memo:
- reports/meta-optimization/ instruction memo:
```
