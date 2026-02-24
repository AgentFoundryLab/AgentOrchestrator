# AgentOrchestrator Issues

**Updated**: 2026-02-24

| ID | Issue | Priority | Status | Task |
|----|-------|----------|--------|------|
| G-001 | OpenCode hooks incompatibility: Claude SH hooks ≠ OpenCode JS/TS plugin system | P2 | 🔲 Open | `docs/knowledge/decisions/non-claude-hooks-policy.md` |
| G-002 | Gemini TOML command transform invalid schema and syntax errors | P1 | ✅ Closed (2026-02-24) | T-092 |
| G-003 | No per-runtime frontmatter schema validation or transform in skills/commands install | P1 | ✅ Closed (2026-02-24) | T-094, T-095 |
| I-001 | ADR-014 D-2 implementation drift: runtime namespace mapping not aligned with accepted decision | P1 | ✅ Closed (2026-02-24) | T-096 |
| I-002 | Gemini capability drift: installer still enforces commands-only despite validated skills/subagents support in docs research (hooks excluded by policy) | P1 | ✅ Closed (2026-02-24) | T-097 |
| I-003 | Legacy compatibility/workaround bloat in installer UX and docs (stale migration text, compat-first wording, fallback markers) | P2 | ✅ Closed (2026-02-24) | T-098 |
| I-004 | Codex default profile still dual-writes deprecated `/prompts:*` artifacts despite skills-first baseline | P1 | ✅ Closed (2026-02-24) | T-100 |
| I-005 | Codex agent invocation alignment with official role-config + `/agent` flow | P1 | ✅ Closed (2026-02-24) | T-099 |

---

## G-001: OpenCode hooks incompatibility

**Type**: Gap
**Discovered**: 2026-02-22
**Affects**: `--opencode` install, `RUNTIME_SUPPORTS_HOOKS[opencode]`, BACKLOG T-063 acceptance criteria wording
**Task**: `docs/knowledge/decisions/non-claude-hooks-policy.md`

Claude SH hooks (`package/hooks/scripts/*.sh`) are invoked as shell commands via Claude Code's `settings.json` hooks system. OpenCode's hook mechanism is a JS/TS plugin event API — it has no facility to invoke shell scripts directly. Copying SH files to `.opencode/plugins/` produces non-functional artifacts.

**Registry fix applied**: `RUNTIME_SUPPORTS_HOOKS[opencode]="false"`, `RUNTIME_HOOKS_PATH[opencode]=""`.

Resolution work is intentionally not scheduled as an implementation task under current policy. Keep open for visibility and periodic reassessment.

---

## G-002: Gemini TOML command transform invalid schema and syntax errors

**Type**: Defect
**Discovered**: 2026-02-22
**Status**: Closed (2026-02-24)
**Affects**: `--gemini --profile commands`
**Task**: T-092

Resolved by `skill_to_gemini_toml` transform producing top-level `description` + `prompt` fields (no `[command]` wrapper), escaping TOML-sensitive characters, and omitting `name` from output.

Validation coverage now includes Gemini commands-profile generation and TOML parsing checks in installer smoke tests.

---

## G-003: No per-runtime frontmatter schema validation or transform

**Type**: Design gap
**Discovered**: 2026-02-22
**Status**: Closed (2026-02-24)
**Affects**: All non-Claude runtimes in both skills and commands install modes
**Task**: T-094, T-095

Resolved by runtime-aware normalization in installer transforms:
- Frontmatter stripping now targets YAML frontmatter only (no body-line removal side effects).
- Claude-specific keys are removed for non-Claude runtimes in both skills and commands flows.
- Commands-mode per-runtime transforms now apply consistently (`{{args}}` conversion for Gemini/Qwen, Codex frontmatter strip, Gemini TOML conversion).
- Runtime key-map + transform contract documented in `package/install/runtimes.sh`.

`--check` frontmatter rows now report `OK` for non-Claude runtimes.

---

## I-001: ADR-014 D-2 drift (runtime mapping implementation)

**Type**: Defect
**Discovered**: 2026-02-22
**Status**: Closed (2026-02-24)
**Affects**: Namespace handling in installer runtime registry and namespace-aware skill copy/restore behavior
**Task**: T-096

Resolved by:
- Artifact-aware namespace registry (`skills`, `agents`, `commands`) aligned to ADR-014 D-2.
- Cleanup paths migrated to the same artifact-aware restore/remove logic used by restore mode.
- ADR-014 namespace-mode guardrail added to runtime registry validation, causing `--check` failures on drift.
- Namespace regression tests updated for dash/native behavior.

---

## I-002: Gemini capability drift vs validated docs baseline

**Type**: Defect
**Discovered**: 2026-02-22
**Status**: Closed (2026-02-24)
**Affects**: `RUNTIME_SUPPORTS_SKILLS[gemini]`, installer profile defaults, conformance tests
**Task**: T-097

Resolved by Gemini skills-first baseline:
- Gemini skills enabled in runtime registry and default profile behavior.
- Gemini commands retained as explicit compatibility mode (`--profile commands`).
- Hooks remain excluded by installer policy and are tested as absent.
- Conformance tests updated to assert skills default + commands-compat behavior.

---

## I-003: Legacy compatibility/workaround bloat in installer UX/docs

**Type**: Quality debt
**Discovered**: 2026-02-22
**Status**: Closed (2026-02-24)
**Affects**: `install.sh --help`, `README.md` migration/compat text, policy-ref legacy marker fallback blocks
**Task**: T-098

Resolved by rewriting installer/README runtime guidance to current behavior-first semantics:
- Skills-first defaults and commands-compat mode are now explicit and non-historical.
- Namespace behavior wording now matches runtime-native translation rules.
- Stale Gemini commands-only and Codex namespace-ignored wording removed.

---

## I-004: Codex skills-first baseline drift (default prompts dual-write)

**Type**: Defect
**Discovered**: 2026-02-24
**Status**: Closed (2026-02-24)
**Affects**: Codex default install flow (`PROFILE=auto`), docs consistency with latest-native policy
**Task**: T-100

Resolved by retaining Codex prompts output exclusively in explicit commands profile flow. Default Codex profile now emits skills only.

---

## I-005: Codex agent invocation alignment vs official docs

**Type**: Defect
**Discovered**: 2026-02-24
**Status**: Closed (2026-02-24)
**Affects**: `reports/research/2026-02-22-agent-capability-report.md`, install/runtime planning artifacts, Codex runtime assumptions
**Task**: T-099

Resolved by codifying Codex official invocation contract in runtime docs/backlog language:
- Enablement via `/experimental` or `multi_agent = true`
- Role definitions via `[agents.<role>]`
- Prompt-driven spawn/routing
- Thread management via `/agent`
