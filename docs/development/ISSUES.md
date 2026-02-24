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
| I-004 | Codex default profile still dual-writes deprecated `/prompts:*` artifacts despite skills-first baseline | P1 | 🔲 Open | T-098 |
| I-005 | MCP baseline drift across PRD/ARCHITECTURE/ADR (required/optional server set inconsistent) | P1 | 🔲 Open | TBD (`/design` + `/spec` sync) |
| I-006 | US5 acceptance criteria have no explicit backlog task trace | P1 | 🔲 Open | TBD (`/plan`) |
| I-007 | NFR coverage gap: NFR1, NFR2, NFR4, NFR5, NFR6 not explicitly traced in backlog | P1 | 🔲 Open | TBD (`/plan`) |
| I-008 | ROADMAP vs BACKLOG drift on v0 scope and task counts (skills count, phase totals) | P1 | 🔲 Open | TBD (`/plan`) |
| I-009 | BACKLOG traceability schema drift: \"User Story\" column contains mixed FR/PRD/ADR/issue/version refs | P1 | 🔲 Open | TBD (`/plan`) |

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

## I-004: Codex skills-first baseline drift (default prompts dual-write)

**Type**: Defect
**Discovered**: 2026-02-24
**Affects**: Codex default install flow (`PROFILE=auto`), docs consistency with latest-native policy
**Task**: T-098

Current installer behavior keeps Codex skills as canonical but also writes legacy prompt artifacts by default (`~/.codex/prompts/*.md`) via auto-profile expansion.

This conflicts with the latest-compatible-only baseline (`docs/knowledge/decisions/latest-compatible-only-policy.md`) where deprecated surfaces should remain transient compatibility, not default behavior.

Expected end state:
- Codex default writes native skills only
- `/prompts:*` artifacts are emitted only in explicit command-mode compatibility flow

Implementation details and AC in T-098.

---

## I-005: MCP baseline drift across PRD/ARCHITECTURE/ADR

**Type**: Defect
**Discovered**: 2026-02-24
**Affects**: `docs/architecture/PRD.md`, `docs/architecture/ARCHITECTURE.md`, ADR summary consistency
**Task**: TBD (`/design` + `/spec` sync)

Current artifact set disagrees on MCP baseline:
- ADR-003 defines 3 required + 2 optional MCP servers.
- ARCHITECTURE text claims 2 required while table marks DeepWiki as required.
- PRD MCP dependency table lists only Serena/Context7 as required.

This creates requirement ambiguity for validation and installer behavior expectations.

---

## I-006: US5 acceptance criteria missing backlog trace

**Type**: Coverage gap
**Discovered**: 2026-02-24
**Affects**: `docs/architecture/PRD.md` user story coverage, `docs/development/BACKLOG.md` traceability
**Task**: TBD (`/plan`)

US5 (Session Reflection) has defined acceptance criteria in PRD but no task row in BACKLOG explicitly references `US5`.

This breaks story-to-task traceability and weakens validation of session reflection behavior.

---

## I-007: NFR traceability gap in backlog

**Type**: Coverage gap
**Discovered**: 2026-02-24
**Affects**: NFR validation planning for v0
**Task**: TBD (`/plan`)

PRD defines NFR1..NFR6, but backlog trace currently references only `NFR3` explicitly.

No explicit task-level trace exists for NFR1, NFR2, NFR4, NFR5, NFR6, making non-functional validation incomplete by artifact evidence.

---

## I-008: ROADMAP vs BACKLOG scope/count drift

**Type**: Defect
**Discovered**: 2026-02-24
**Affects**: `docs/objectives/ROADMAP.md` progress integrity, release reporting
**Task**: TBD (`/plan`)

ROADMAP progress and scope lines no longer match BACKLOG reality:
- v0 scope line still states 14 skills.
- Progress table counts do not match current backlog phase totals.

This causes reporting drift and makes milestone completion status ambiguous.

---

## I-009: BACKLOG traceability schema drift

**Type**: Design gap
**Discovered**: 2026-02-24
**Affects**: `docs/development/BACKLOG.md` reviewability and automated checks
**Task**: TBD (`/plan`)

BACKLOG column header is `User Story`, but values include mixed references (`FR*`, `PRD`, `ADR-*`, issue IDs, version labels).

As a result, many tasks are not explicitly traceable to FR/NFR in a machine-checkable way.

---
