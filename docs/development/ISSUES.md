# AgentOrchestrator Issues

**Updated**: 2026-02-22

| ID | Issue | Priority | Status | Task |
|----|-------|----------|--------|------|
| G-001 | OpenCode hooks incompatibility: Claude SH hooks ≠ OpenCode JS/TS plugin system | P2 | 🔲 Open | T-093 |
| G-002 | Gemini TOML transform not implemented: SKILL.md → `.toml` commands skipped | P1 | 🔲 Open | T-092 |
| G-003 | No per-runtime frontmatter schema validation or transform in skills/commands install | P1 | 🔲 Open | T-094 |

---

## G-001: OpenCode hooks incompatibility

**Type**: Gap
**Discovered**: 2026-02-22
**Affects**: `--opencode` install, `RUNTIME_SUPPORTS_HOOKS[opencode]`
**Task**: T-093

Claude SH hooks (`package/hooks/scripts/*.sh`) are invoked as shell commands via Claude Code's `settings.json` hooks system. OpenCode's hook mechanism is a JS/TS plugin event API — it has no facility to invoke shell scripts directly. Copying SH files to `.opencode/plugins/` produces non-functional artifacts.

**Registry fix applied**: `RUNTIME_SUPPORTS_HOOKS[opencode]="false"`, `RUNTIME_HOOKS_PATH[opencode]=""`.

Implementation details and AC in T-093.

---

## G-002: Gemini TOML command transform not implemented

**Type**: Gap
**Discovered**: During v0.2.0 implementation (T-076 deferred)
**Affects**: `--gemini` install (default and `--profile commands`)
**Task**: T-092

Gemini CLI commands are `.toml` files. The installer has no SKILL.md → TOML transform. `install.sh --gemini` skips commands install with a warning; `--check` shows `TBD` for the gemini commands row.

Implementation details and AC in T-092.

---

## G-003: No per-runtime frontmatter schema validation or transform

**Type**: Design gap
**Discovered**: 2026-02-22
**Affects**: All non-Claude runtimes in both skills and commands install modes
**Task**: T-094

**Skills mode**: `copy_directory` copies SKILL.md verbatim. Claude-specific keys (`argument-hint`, `user-invocable`) land in Codex/Qwen installs unchanged. Whether those runtimes silently ignore unknown keys or reject them is untested.

**Commands mode**: Codex strips the entire frontmatter block (loses `name`/`description`). OpenCode and Qwen receive verbatim SKILL.md including YAML frontmatter — unknown whether commands files expect frontmatter at all.

No schema registry exists defining which keys are supported, dropped, or transformed per runtime × mode.

Implementation details and AC in T-094.

---
