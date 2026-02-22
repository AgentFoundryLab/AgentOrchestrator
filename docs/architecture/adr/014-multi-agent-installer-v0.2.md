# ADR-014: Multi-Agent Installer v0.2 Design Decisions

**Status**: Accepted
**Date**: 2026-02-20
**Context**: v0.2/multi-agent-install branch — extending the installer from 3 runtimes to 5 with capability-scoped profiles

---

## Context

v0.1.x `install.sh` targets a single runtime: Claude Code. It installs agents, skills, hooks, scripts, and policy references under `~/.claude/` (global) and `.claude/` (project). Three runtime flags (`--claude`, `--gemini`, `--codex`) existed but controlled only which context docs received policy-ref injections — not which runtime's artifact paths were written.

v0.2.0 extends the installer to five runtimes:

| Runtime     | Flag         |
| ----------- | ------------ |
| Claude Code | `--claude`   |
| Codex CLI   | `--codex`    |
| Gemini CLI  | `--gemini`   |
| OpenCode    | `--opencode` |
| Qwen Code   | `--qwen`     |

Each runtime has a distinct capability set (commands, skills, hooks, scripts), distinct filesystem paths, and distinct artifact formats. The installer must handle all five without cross-runtime collisions, while remaining backward compatible with v0.1.x installs.

Four design questions required explicit decisions before implementation:

1. What do the runtime flags (`--claude`, `--codex`, etc.) mean and control?
2. How does namespace support work across runtimes that have different namespace mechanisms?
3. How are scripts modeled — embedded in skill packages or as standalone artifacts?
4. Where does the canonical runtime path registry live, and how is it sourced?

---

## Decision

### D-1: Flag Semantics — Install Targets, Not Runtime Selectors

**Decision**: The flags `--claude`, `--codex`, `--gemini`, `--opencode`, `--qwen` control which runtime's artifact paths are written during install. They are install target selectors, not runtime execution selectors. Multiple flags may be combined in a single invocation. When none are provided, the installer writes to all supported runtimes.

**Clarification from v0.1.x**: In v0.1.x these flags narrowed only the policy-ref injection targets (CLAUDE.md, AGENTS.md, GEMINI.md). That behavior was ambiguous and incomplete. v0.2.0 formalizes them as install target selectors: each flag gates an entire runtime's artifact installation, including paths, capabilities, and policy refs.

**Backward compatibility**: `--claude` in v0.1.x wrote to `~/.claude/` unconditionally and used the flag only to gate ref injection. In v0.2.0, `--claude` with no other runtime flags produces the same artifact set as v0.1.x (skills, hooks, scripts, settings, refs). Existing installs are unaffected.

---

### D-2: Per-Agent Namespace Strategy

**Decision**: Namespace support is per-runtime, not universal. Flat mode (no namespace) is the default for all runtimes and is backward compatible.

Per-runtime namespace semantics:

| Runtime     | Namespace Mechanism                                                    | Namespaced Invocation |
| ----------- | ---------------------------------------------------------------------- | --------------------- |
| Claude Code | Dot-prefix on skill dir: `skills/<ns>.<skill>/` + `name: <ns>.<skill>` | `/<ns>.<skill>`       |
| Codex CLI   | Same dot-prefix convention: `skills/<ns>.<skill>/`                     | `/<ns>.<skill>`       |
| Gemini CLI  | Subdirectory nesting: `commands/<ns>/<cmd>.toml`                       | `/<ns>:<cmd>`         |
| OpenCode    | Subdirectory nesting (reads `.opencode/skills/<ns>/`)                  | `/<ns>:<skill>`       |
| Qwen Code   | Dot-prefix on skill dir (mirrors Claude/Codex convention)              | `/<ns>.<skill>`       |

**Namespace grammar** (applies to all runtimes): dot-separated segments, each matching `[a-z][a-z0-9-]*`. Maximum depth: 3 segments (e.g., `orchestrator.project`). Validation runs at install start when `--namespace` is provided; invalid values produce a non-zero exit with an error message.

**Flat default**: When `--namespace` is omitted, all runtimes install at flat paths. This is the default and is explicitly documented in `--help`.

**Mapping rule for dot-notation to path**: Dot separators in the namespace are translated to path separators only for runtimes that use subdirectory nesting (Gemini, OpenCode). For dot-prefix runtimes (Claude, Codex, Qwen), the namespace is kept as a dot-separated prefix on the artifact directory name.

---

### D-3: Scripts Artifact Model — Embedded Per Runtime

**Decision**: Scripts support is defined per runtime in the registry. Scripts are embedded within skill packages rather than installed as standalone path artifacts.

Per-runtime scripts model:

| Runtime     | Scripts Model                                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------------------------ |
| Claude Code | `scripts/` subdirectory within each skill package under `.claude/skills/<skill>/scripts/`                          |
| Codex CLI   | `scripts/` subdirectory within each skill package under `.agents/skills/<skill>/scripts/`                          |
| Gemini CLI  | Inline shell execution via `!{...}` in command bodies; no separate scripts directory installed                     |
| OpenCode    | `scripts/` within skill packages under `.opencode/skills/<skill>/scripts/`; plugin scripts in `.opencode/plugins/` |
| Qwen Code   | `scripts/` within skill packages under `.qwen/skills/<skill>/scripts/`; inline `!{command}` in commands            |

Scripts are not a separate install step. When the installer copies a skill package directory, any `scripts/` subdirectory it contains is copied as part of that package. No additional installer logic is required beyond the existing `copy_directory` function.

For runtimes without a native scripts directory (Gemini), the installer records scripts capability as `inline-only` in the registry. No `scripts/` directory is created for Gemini targets.

---

### D-4: Registry Extraction — Dedicated Sourced Shell File

**Decision**: Extract all canonical runtime path definitions into `package/install/runtimes.sh`. This file is sourced by `install.sh` at startup. It is the single source of truth for all runtime paths, capability flags, and format metadata.

**File path**: `package/install/runtimes.sh`

**Format**: Bash associative arrays or indexed parallel arrays (bash 4+) defining per-runtime:

- Project install root (e.g., `.claude/`, `.agents/`, `.gemini/`, `.opencode/`, `.qwen/`)
- Global install root (e.g., `~/.claude/`, `~/.agents/`, `~/.gemini/`, `~/.config/opencode/`, `~/.qwen/`)
- Skills path (relative to install root, or `""` if not supported)
- Commands path (relative to install root)
- Hooks path (relative to install root, or `""` if not supported)
- Scripts model (`embedded`, `inline-only`)
- Commands format (`md`, `toml`)
- Capability bitmask or flags: `supports_skills`, `supports_hooks`
- Policy context doc name (e.g., `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`)

**Sourcing mechanism**: `install.sh` sources `package/install/runtimes.sh` at the top of `main()` via `. "${PACKAGE_DIR}/install/runtimes.sh"`. No subshell — variables must be visible in the caller.

**No hardcoded paths outside registry**: Any function in `install.sh` that resolves a runtime path MUST read it from the registry arrays. Hardcoded path strings for runtime-specific locations are forbidden after T-058 is complete.

**Drift check**: A `--check` mode (T-065) will compare resolved paths against registry values at runtime and in CI (T-091).

---

### D-5: Frontmatter Transform Strategy

#### Minimal universal MD schema (T-094)

Strip Claude-specific keys from SKILL.md when installing to non-Claude runtimes. Universal portable set: `name`, `description`. Claude-specific keys (`argument-hint`, `user-invocable`, `context`, `agent`) dropped at install time for all non-Claude targets. Commands mode: `$ARGUMENTS` → `{{args}}` for Qwen and Gemini.

`--check` shows `PARTIAL` for non-Claude skills/commands/agents rows until T-094 is done; `OK` once applied.

#### Gemini TOML format conversion (T-092, standalone)

Format-only transform: SKILL.md Markdown → Gemini `.toml`. Extracts `name` and `description` from frontmatter, places body as `prompt` TOML multiline string. Unknown keys passed through (T-094 strips Claude-specific keys before T-092 runs). T-092 is **not** folded into T-095 — it addresses a distinct format conversion requirement.

`--check` gemini commands row: `GAP` → `OK` once T-092 done.

#### Per-runtime key map + TOML schema adjustments (T-095)

Explicit `runtime × mode × key → action` rules beyond the minimal strip. Covers runtime-specific extensions (Codex invocation field, Gemini TOML structural requirements beyond basic format, OpenCode hooks binding). Depends on T-094 and T-092 being complete.

`--check` non-Claude frontmatter rows: `PARTIAL` → `OK` once T-095 done.

**Official schema findings** (from docs research):
- Qwen commands: only `description` documented; `name`+`description` required for skills
- Gemini commands: `name`, `description`, `prompt` in TOML
- Argument placeholder: `$ARGUMENTS` (Claude) vs `{{args}}` (Qwen, Gemini — confirmed official docs)

---

## Rationale

### Why per-runtime namespace semantics rather than a universal grammar?

A universal grammar would require a lowest-common-denominator approach that either loses expressive power (subdirectory nesting not supported everywhere) or produces inconsistent invocation syntax across runtimes (dot-prefix working one way for Claude but mapped differently for Gemini). Each runtime's native mechanism is preserved, and the installer maps the common `--namespace` input to each runtime's appropriate output. The user provides one namespace string; the installer translates it correctly per target.

### Why embedded scripts rather than a standalone scripts install step?

Skill packages are self-contained units. A skill that ships helper scripts expects them to be co-located with the skill definition. Installing skills and scripts in separate passes creates a partial-install risk (skill without its scripts). Embedding them means the `copy_directory` function handles scripts automatically with no additional code path. For runtimes that only support inline scripts (Gemini), no directory is created — this is a capability difference already captured in the registry.

### Why `package/install/runtimes.sh` rather than a JSON or TOML registry?

The installer is a bash script. A bash-sourced file requires no additional tool dependencies (no `jq` needed for the registry itself, unlike settings.json merging). The registry is queried repeatedly during install; a bash-native data structure has zero parsing overhead. JSON was considered (consistent with settings.json pattern) but would require `jq` for every path lookup, adding fragility to the core install path. A separate `install/` subdirectory under `package/` keeps the registry co-located with the installer without polluting the package root.

---

## Alternatives Considered

### Alternative for D-2: Universal dot-notation grammar for all runtimes

Apply dot-notation uniformly: all runtimes use `<ns>.<skill>/` directory naming and `/<ns>.<skill>` invocation.

**Rejected**: Gemini CLI uses subdirectory nesting for its namespace model (`commands/<ns>/<cmd>.toml` → `/<ns>:<cmd>`). Forcing dot-notation on Gemini would produce artifact paths that Gemini does not recognize as namespaced. Per-runtime translation is the only approach that respects each runtime's documented behavior.

### Alternative for D-2: Suppress namespace for runtimes that use subdirectory nesting

Allow `--namespace` only for dot-prefix runtimes; emit a warning and skip namespace application for Gemini and OpenCode.

**Rejected**: Gemini and OpenCode have valid namespace mechanisms. Silently skipping namespacing for those runtimes when the user explicitly provides `--namespace` is confusing. Correct translation is preferable to silent skipping.

### Alternative for D-3: Standalone scripts install step

Install a `scripts/` directory at the runtime root level, separate from skill packages (e.g., `.claude/scripts/` as a peer to `.claude/skills/`).

**Rejected**: No runtime has a documented standalone scripts root separate from skill/command packages. Installing to an undocumented path produces scripts that runtimes will not locate. Embedding within skill packages matches the documented runtime behavior for all five runtimes.

### Alternative for D-3: No scripts installation (document-only)

Do not install scripts at all; document that users must manage scripts manually.

**Rejected**: Hook scripts are functional requirements for Claude Code (T-001 through T-005 are all hook scripts). Removing scripts installation would regress existing Claude Code functionality. Other runtimes' embedded scripts are needed for skills that invoke helper workflows.

### Alternative for D-4: JSON registry file

Store runtime metadata in `package/install/runtimes.json`, parsed via `jq` in `install.sh`.

**Rejected**: `jq` is required for settings.json merging but adds a hard dependency for path lookups if used for the registry. A bash-native registry has zero additional dependencies. The registry structure (associative arrays of strings) maps naturally to bash; no benefit from JSON encoding.

### Alternative for D-4: Inline constants in install.sh

Keep all path definitions as local variables or constants inside `install.sh` functions.

**Rejected**: This is the current state and is what T-058 explicitly addresses. Inline constants in a 1200-line script are not auditable, produce the path-drift problem that T-065 and T-091 target, and make it impossible to add a fifth or sixth runtime without editing core logic throughout the file.

---

## Consequences

### Impact on T-058..T-070 implementation

**T-058 (Define canonical runtime registry)**: Creates `package/install/runtimes.sh` per D-4. All five runtimes defined with paths matching the research report matrix. This task must be completed first — all subsequent installer tasks depend on it.

**T-059 (Add --opencode and --qwen flags)**: Straightforward once registry exists. Flag parsing in `main()` gains two cases; install/restore/cleanup dispatch gains two branches.

**T-060..T-064 (Codify per-runtime paths)**: Each task validates that the registry entry for its runtime matches the canonical paths. Implementation work is verifying the registry, not writing new path logic throughout the script.

**T-065 (Runtime path drift checks)**: Reads registry and cross-checks any computed paths. Requires D-4 registry to be in place.

**T-066 (Frontmatter/schema transforms)**: Transform spec documents how `SKILL.md` frontmatter maps to each runtime's commands format. Operates independently of the registry but must reference the registry's `commands_format` field per runtime.

**T-067 (Namespace grammar and validation)**: Implements the grammar defined in D-2. Validation function is a standalone helper sourced from `package/install/runtimes.sh` or a companion `namespace.sh`.

**T-068 (Map dot-notation to agent paths)**: Implements the per-runtime translation table from D-2. Pure function: namespace string + runtime ID → path prefix.

**T-069 (Preserve flat mode)**: No change to default behavior. D-2 flat-default decision confirms backward compatibility.

**T-070 (Namespace-safe restore/cleanup)**: Restore and cleanup functions read `--namespace` and apply the per-runtime translation from D-2 to identify the correct subtree to target. Cross-namespace collision safety follows from namespaced subtrees being disjoint path prefixes.

### Positive

- Single registry eliminates path drift between installer logic and documented runtime paths
- Per-runtime capability flags allow unsupported-capability warnings (T-079) without conditional logic scattered through install functions
- Flat default preserves all v0.1.x installs without migration
- Per-runtime namespace translation gives correct native behavior for all five runtimes without a lowest-common-denominator compromise
- Embedded scripts model requires no new install code paths

### Negative

- `package/install/runtimes.sh` adds a new sourced file that must be kept consistent with the research report matrix
- Per-runtime namespace translation logic is more complex than a single universal mapping
- Bash associative arrays require bash 4+; macOS ships bash 3.2 by default (mitigated: installer already uses bash 4 features; `brew install bash` is documented)

### Mitigations

- T-065 and T-091 provide drift detection and CI enforcement to catch registry divergence
- Namespace translation is isolated in a pure function (T-068) independently testable
- macOS bash version constraint is an existing documented requirement, not introduced by this ADR

---

## Related

- [ADR-004](004-skill-agent-invocation-paths.md) — Skill-agent invocation paths (skill naming conventions that namespace builds on)
- [ADR-006](006-policy-modularization.md) — Policy modularization (policy-ref injection extended by D-1 for all 5 runtimes)
- [ADR-008](008-multi-provider-integration-strategy.md) — Multi-provider integration strategy (runtime capability matrix context)
- [ADR-013](013-extended-skills.md) — Extended skills (governance skills whose install behavior is governed by this ADR)
- `docs/knowledge/decisions/flat-skill-paths.md` — Flat vs dot-prefix skill paths decision record (D-2 builds on this)
- `reports/research/2026-02-19-multi-agent-install-plan.md` — Canonical capability matrix (source of truth for registry values)
- `docs/development/ISSUES.md` — G-003 (frontmatter schema gap), G-001 (OpenCode hooks), G-002 (Gemini TOML)
- `/workspace/spec-kit/src/specify_cli/extensions.py` — Reference implementation: `CommandRegistrar` transform pipeline
- BACKLOG T-058..T-091 — Implementation tasks for this architecture
