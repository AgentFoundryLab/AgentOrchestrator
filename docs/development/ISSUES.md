# AgentOrchestrator Issues

**Updated**: 2026-02-25

| ID | Issue | Priority | Status | Task |
|----|-------|----------|--------|------|
| G-001 | OpenCode hooks incompatibility: shell hooks are not natively compatible with OpenCode plugin model | P2 | 🔲 Open | `docs/knowledge/decisions/non-claude-hooks-policy.md` |
| I-002 | Gemini capability drift: installer behavior still diverges from expected skills/subagents baseline | P1 | 🔄 Reopened (2026-02-24) | T-097 |
| I-006 | Runtime target isolation + Gemini command transform regression: decoupling fixes landed, but Gemini command files still fail loader validation/parse | P0 | 🔄 Open (2026-02-25) | T-097 |

---

## Active Issue Details

### G-001: OpenCode hooks incompatibility

**Type**: Gap  
**Discovered**: 2026-02-22  
**Affects**: OpenCode install flow and runtime capability expectations  
**Task**: `docs/knowledge/decisions/non-claude-hooks-policy.md`

OpenCode hook integration does not support the same shell-hook execution model used by Claude. Under current policy, non-Claude hooks remain intentionally out of scope.

---

### I-002: Gemini capability drift vs expected baseline

**Type**: Defect  
**Discovered**: 2026-02-22  
**Status**: Reopened (2026-02-24)  
**Affects**: Gemini capability modeling, installer defaults, and conformance behavior  
**Task**: T-097

The issue was previously marked closed but has been reopened because behavior is still reported as broken.

Current action:
- Keep issue active until capability behavior is re-validated end-to-end.
- Keep linked backlog task in progress.
- Do not archive until objective validation confirms closure.

---

### I-006: Runtime target isolation + Gemini command transform regression

**Type**: Defect  
**Discovered**: 2026-02-25  
**Status**: Open (2026-02-25)  
**Affects**: Global installer target isolation, runtime-scoped policy-reference injection, and Gemini command compatibility profile output  
**Task**: T-097

Observed behavior (2026-02-25):
- Historical regression (addressed in current branch):
  - `./install.sh --global --overwrite --codex` touched `~/.claude/*` shared global paths
  - `./install.sh --global --overwrite --gemini --uninstall` removed `~/.claude/*` without `--claude`
  - policy refs in non-Claude docs pointed to `@~/.claude/policy/*`
- Active blocking regression (still open):
  - Gemini commands profile emits invalid `.toml` files under `~/.gemini/commands/`
  - Gemini CLI `FileCommandLoader` reports parse/validation failures, including:
    - parse failures: `research.toml`, `orchestrate.toml`
    - validation failures: `validate.toml`, `review.toml`, `reflexion.toml`, `reflect.toml`, `plan.toml`, `spec.toml`, `optimize.toml`, `onboard.toml`, `implement.toml`, `hitl.toml`, `document.toml`, `distill.toml`, `design.toml`, `deploy.toml`, `analyse.toml`

Expected behavior:
- Runtime target flags are strictly isolated for install/uninstall (`--codex` and `--gemini` must not write/remove `~/.claude/*` unless `--claude` is selected)
- Global policy/workflow/template assets are installed and cleaned in each selected runtime target directory
- Policy refs are runtime-scoped per selected agent runtime:
  - Codex: `Read @~/.agents/policy/PRINCIPLES.md`
  - Gemini: `Read @~/.gemini/policy/PRINCIPLES.md`
  - (and equivalent runtime-local paths for other runtimes)
- Gemini commands profile output must satisfy Gemini CLI parser + schema validation for all generated command files

Current action:
- Keep issue open until both are true:
  - zero `.claude/*` side effects for non-Claude-only global operations
  - zero Gemini `FileCommandLoader` parse/validation errors across generated `.gemini/commands/*.toml`
- Add/expand regression coverage for real Gemini command schema constraints (not only TOML syntax parsing)

---

## Resolved Issues Archive

Resolved issues were moved to:
- [archive/issues-resolved-2026-02-24.md](archive/issues-resolved-2026-02-24.md)
- [archive/issues-resolved-2026-02-25.md](archive/issues-resolved-2026-02-25.md)
