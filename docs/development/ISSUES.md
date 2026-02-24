# AgentOrchestrator Issues

**Updated**: 2026-02-24

| ID | Issue | Priority | Status | Task |
|----|-------|----------|--------|------|
| G-001 | OpenCode hooks incompatibility: Claude SH hooks ≠ OpenCode JS/TS plugin system | P2 | 🔲 Open | `docs/knowledge/decisions/non-claude-hooks-policy.md` |
| G-002 | Gemini TOML command transform invalid schema and syntax errors | P1 | 🔲 Open | T-092 |
| G-003 | No per-runtime frontmatter schema validation or transform in skills/commands install | P1 | 🔲 Open | T-094 |
| I-001 | ADR-014 D-2 implementation drift: runtime namespace mapping not aligned with accepted decision | P1 | 🔲 Open | T-096 |
| I-002 | Gemini capability drift: installer still enforces commands-only despite validated skills/subagents support in docs research (hooks excluded by policy) | P1 | 🔲 Open | T-097 |
| I-003 | Legacy compatibility/workaround bloat in installer UX and docs (stale migration text, compat-first wording, fallback markers) | P2 | 🔲 Open | T-098 |
| I-004 | Codex default profile still dual-writes deprecated `/prompts:*` artifacts despite skills-first baseline | P1 | 🔲 Open | T-100 |
| I-005 | Codex agent invocation alignment pending: installer/runtime model still needs role-config + `/agent` conformity | P1 | 🔲 Open | T-099 |

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

## I-001: ADR-014 D-2 drift (runtime mapping implementation)

**Type**: Defect
**Discovered**: 2026-02-22
**Affects**: Namespace handling in installer runtime registry and namespace-aware skill copy/restore behavior
**Task**: T-096

ADR-014 D-2 defines runtime-native namespace behavior with flat mode as default for all runtimes, and optional `--namespace` applied only where the selected runtime/profile supports namespace semantics.

Current installer runtime registry still has legacy namespace modes that can synthesize namespaced skill identifiers for runtimes/artifacts that should remain flat under ADR-014 D-2.

`docs/architecture/ARCHITECTURE.md` has already been updated to runtime-native installation targets. Remaining drift is in installer/runtime constants and behavior, not architecture documentation.

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

## I-004: Codex skills-first baseline drift (default prompts dual-write)

**Type**: Defect
**Discovered**: 2026-02-24
**Affects**: Codex default install flow (`PROFILE=auto`), docs consistency with latest-native policy
**Task**: T-100

Current installer behavior keeps Codex skills as canonical but also writes legacy prompt artifacts by default (`~/.codex/prompts/*.md`) via auto-profile expansion.

This conflicts with the latest-compatible-only baseline (`docs/knowledge/decisions/latest-compatible-only-policy.md`) where deprecated surfaces should remain transient compatibility, not default behavior.

Expected end state:
- Codex default writes native skills only
- `/prompts:*` artifacts are emitted only in explicit command-mode compatibility flow

Implementation details and AC in T-100.

---

## I-005: Codex agent invocation alignment pending vs official docs

**Type**: Defect
**Discovered**: 2026-02-24
**Affects**: `reports/research/2026-02-22-agent-capability-report.md`, install/runtime planning artifacts, Codex runtime assumptions
**Task**: T-099

Official Codex docs define multi-agent invocation via experimental enablement + role config in `config.toml` (`[agents.<role>]`) and thread management via `/agent`.

Documentation updates are in progress, but installer/runtime planning still needs explicit conformity with the official Codex role-config model and thread workflow.

Expected end state:
- Codex invocation docs consistently state: `/experimental` (or `multi_agent = true`), role config, prompt-based spawn, `/agent` thread switching.
- Installer/runtime plan and behavior track Codex role-config alignment as explicit work.

Implementation details and AC in T-099.

---
