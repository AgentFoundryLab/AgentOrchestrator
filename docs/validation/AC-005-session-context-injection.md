# Coverage: AC-005.2, AC-005.4 — SessionStart context injection

Date: 2026-08-14 · Serves `ISS-007`

Scope is exactly two acceptance criteria. `REQ-005`'s other seven are **not** covered here and
remain without evidence; `docs/development/status/STATUS.md` states that gap for the record set as a
whole.

## Method

The hook is driven directly with a synthetic payload on stdin — the same shape Claude Code sends —
and stdout is asserted. No installed copy is involved, so the evidence is about
`package/hooks/scripts/inject-context.sh` at the commit below, not about a deployed artifact.

```bash
echo '{"hook_event_name":"SessionStart","session_id":"test-sess-123","cwd":"'"$PWD"'","source":"startup"}' \
  | bash package/hooks/scripts/inject-context.sh
```

## Results

| Criterion | Requirement | Observed | Result |
|---|---|---|---|
| `AC-005.2` | On `SessionStart`, make relevant project knowledge discoverable | `Knowledge: docs/knowledge/ — decisions, domain, patterns, README.md, runbooks` | Pass |
| `AC-005.4` | On `SessionStart`, inject `PROJECT_NAME` derived from the working directory as a path slug | `PROJECT_NAME=orchestrator` | Pass |

Three paths were exercised:

1. **`SessionStart` with a knowledge base** — both values emitted, entries comma-separated.
2. **`SubagentStart`** — neither value emitted, by design. A sub-agent inherits its parent's context;
   this asserts the change did not leak into the per-spawn path.
3. **`SessionStart` with no `docs/knowledge/`** — `PROJECT_NAME` emitted, knowledge line absent, exit 0.
   Absence degrades silently rather than erroring.

`shellcheck` passes on the changed script via `pre-commit run shellcheck`.

## Limits of this evidence

- **Not an installed-path test.** It proves the source script's behavior. Nothing here proves Claude
  Code delivers this payload shape, invokes the hook at `SessionStart`, or places the stdout into
  context — that is runtime behavior no test in this repository exercises.
- **Hooks are opt-in.** They install only with `--hooks`, and only on Claude Code. On any other
  runtime these two criteria have no implementation at all, which is a coverage gap in `REQ-005`
  rather than a defect in this fix.
- **Cap not exercised at boundary.** The 12-entry cap was read from the code, not driven with a
  13-entry knowledge base.

## Commit

`5ae775e` — `fix(hooks): inject PROJECT_NAME and the knowledge index at SessionStart`
