# AgentOrchestrator Issues

**Updated**: 2026-02-24

| ID | Issue | Priority | Status | Task |
|----|-------|----------|--------|------|
| G-001 | OpenCode hooks incompatibility: Claude SH hooks ≠ OpenCode JS/TS plugin system | P2 | 🔲 Open | `docs/knowledge/decisions/non-claude-hooks-policy.md` |
| G-002 | Gemini TOML command transform invalid schema and syntax errors | P1 | 🔲 Open | T-092 |
| G-003 | No per-runtime frontmatter schema validation or transform in skills/commands install | P1 | 🔲 Open | T-094 |
| I-001 | ADR-014 D-2 drift: runtime namespace mapping and architecture install model not aligned with accepted decision | P1 | 🔲 Open | T-096 |
| I-002 | Gemini capability drift: installer still enforces commands-only despite validated skills/subagents support in docs research (hooks excluded by policy) | P1 | 🔲 Open | T-097 |
| I-003 | Legacy compatibility/workaround bloat in installer UX and docs (stale migration text, compat-first wording, fallback markers) | P2 | 🔲 Open | T-098 |

---

## G-001: OpenCode hooks incompatibility

**Type**: Gap
**Discovered**: 2026-02-22
**Affects**: `--opencode` install, `RUNTIME_SUPPORTS_HOOKS[opencode]`
**Task**: `docs/knowledge/decisions/non-claude-hooks-policy.md`

Claude SH hooks (`package/hooks/scripts/*.sh`) are invoked as shell commands via Claude Code's `settings.json` hooks system. OpenCode's hook mechanism is a JS/TS plugin event API — it has no facility to invoke shell scripts directly. Copying SH files to `.opencode/plugins/` produces non-functional artifacts.

**Registry fix applied**: `RUNTIME_SUPPORTS_HOOKS[opencode]="false"`, `RUNTIME_HOOKS_PATH[opencode]=""`.

Resolution work is intentionally not scheduled as an implementation task under current policy. Keep open for visibility and periodic reassessment.

---

## G-002: Gemini TOML command transform invalid schema and syntax errors

**Type**: Defect
**Discovered**: 2026-02-22
**Affects**: `--gemini` install (default and `--profile commands`)
**Task**: T-092

Gemini CLI commands are `.toml` files. The installer's SKILL.md → TOML transform uses an incorrect schema (wraps fields in a `[command]` table) and fails to properly escape backslashes in the body, leading to `tomllib.TOMLDecodeError` on load.

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

## I-001: ADR-014 D-2 drift (runtime mapping + architecture model)

**Type**: Defect
**Discovered**: 2026-02-22
**Affects**: Namespace handling in installer runtime registry, namespace-aware skill copy/restore behavior, and `docs/architecture/ARCHITECTURE.md` install model
**Task**: T-096

ADR-014 D-2 defines runtime-native namespace behavior with flat mode as default for all runtimes, and optional `--namespace` applied only where the selected runtime/profile supports namespace semantics.

Current installer runtime registry still has legacy namespace modes that can synthesize namespaced skill identifiers for runtimes/artifacts that should remain flat under ADR-014 D-2.

`ARCHITECTURE.md` installation targets still model Claude-only paths and namespace behavior, while ADR-014 defines a multi-runtime capability baseline (Claude/Codex/Gemini/OpenCode/Qwen).

Implementation details and AC in T-096.

---

## I-002: Gemini capability drift vs validated docs baseline

**Type**: Defect
**Discovered**: 2026-02-22
**Affects**: `RUNTIME_SUPPORTS_SKILLS[gemini]`, installer profile defaults, conformance tests
**Task**: T-097

Official docs revalidation and research reports identify Gemini skills/subagents support, but installer registry and tests still hardcode Gemini as commands-only (`no skills`). Hooks are intentionally excluded by project policy for non-Claude runtimes.

This creates behavioral drift between architecture/research docs and shipped installer behavior.

Implementation details and AC in T-097.

---

## I-003: Legacy compatibility/workaround bloat in installer UX/docs

**Type**: Quality debt
**Discovered**: 2026-02-22
**Affects**: `install.sh --help`, `README.md` migration/compat text, policy-ref legacy marker fallback blocks
**Task**: T-098

Installer UX/docs still contain legacy-first compatibility wording and version-history narration that is not needed for current behavior specification. This increases ambiguity and hides current runtime constraints behind migration prose.

Implementation details and AC in T-098.

---
