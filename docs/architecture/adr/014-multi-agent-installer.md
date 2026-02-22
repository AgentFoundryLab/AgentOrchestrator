# ADR-014: Multi-Agent Installer v0.2 Design Decisions

**Status**: Accepted
**Date**: 2026-02-20
**Context**: Multi-runtime installer architecture and runtime capability mapping.

---

## Context

The installer targets five runtimes:

| Runtime     | Flag         |
| ----------- | ------------ |
| Claude Code | `--claude`   |
| Codex CLI   | `--codex`    |
| Gemini CLI  | `--gemini`   |
| OpenCode    | `--opencode` |
| Qwen Code   | `--qwen`     |

Each runtime has a distinct capability set (subagents, commands, skills, hooks, scripts), distinct filesystem paths, and distinct artifact formats. The installer must handle all five without cross-runtime collisions.

Five design questions required explicit decisions before implementation:

1. What do the runtime flags (`--claude`, `--codex`, etc.) mean and control?
2. How does namespace support work across runtimes that have different namespace mechanisms?
3. How are scripts modeled — embedded in skill packages or as standalone artifacts?
4. Where does the canonical runtime path registry live, and how is it sourced?
5. What is the current (officially documented) capability baseline across runtimes, including the missing `subagents` dimension?

---

## Decision

### D-1: Flag Semantics — Install Targets, Not Runtime Selectors

**Decision**: The flags `--claude`, `--codex`, `--gemini`, `--opencode`, `--qwen` control which runtime's artifact paths are written during install. They are install target selectors, not runtime execution selectors. Multiple flags may be combined in a single invocation. When none are provided, the installer writes to all supported runtimes.

---

### D-1A: Capability Baseline — Include Subagents and Runtime-Specific Hook Semantics

**Decision**: The installer capability registry and architecture docs must track `subagents` as a first-class capability dimension alongside commands, skills, hooks, and scripts.

Capability baseline:

| Runtime | subagents | commands | skills | hooks | scripts |
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| Claude Code | Yes | Yes | Yes | Yes | Yes |
| Codex CLI | Yes (experimental multi-agent roles) | Yes (custom prompts deprecated) | Yes | Limited (`notify` callback; not a full lifecycle hook map) | Yes |
| Gemini CLI | Partial/experimental agents (`agents.overrides` official; file-based agents inferred from secondary docs) | Yes | Yes | Yes | Yes |
| OpenCode | Yes | Yes | Yes | Yes (plugin event hooks) | Yes |
| Qwen Code | Yes | Yes | Yes | No documented user-facing lifecycle hook schema | Yes |

**Consequence**: Runtime checks, documentation tables, and registry metadata should never infer `hooks` parity from a boolean alone; Codex and Qwen differ materially from Claude/Gemini/OpenCode in current official docs.

---

### D-2: Per-Agent Namespace Strategy

**Decision**: Namespace is modeled per runtime and per artifact type. Flat mode (no namespace) is the default for all runtimes. `--namespace` is optional and is only applied where a runtime documents a compatible namespace mechanism.

Per-runtime namespace semantics (official docs baseline, 2026-02-22):

| Runtime | Skills/Subagents naming | Commands naming | Invocation form |
| ----------- | ----------- | ----------- | ----------- |
| Claude Code | Flat skill and subagent names (`<name>`). Plugin skills use plugin-owned namespace `plugin-name:skill-name`. | Custom slash commands are unified with skills; flat `/name` for project/user commands. | Skills/commands: `/name`; plugins: `plugin-name:skill-name` |
| Codex CLI | Flat skill names from `.agents/skills/<name>/SKILL.md`. | N/A for installer namespace strategy in this ADR (Codex skills are invoked via skill mention flow). | Skill mention (`$skill`) / `/skills` management UI |
| Gemini CLI | Agent overrides are config-scoped (`agents.overrides`), not path-name namespace. | Native namespacing via directories: `commands/<ns>/<cmd>.toml` -> `/<ns>:<cmd>` | `/<ns>:<cmd>` |
| OpenCode | Flat skill names with strict regex (`^[a-z0-9]+(-[a-z0-9]+)*$`), and flat subagent names (from agent id/file). | No separate command namespace mechanism used by installer in this ADR. | Skills via `skill({name})`; subagents via `@agent` |
| Qwen Code | Flat skill/subagent names (directory/file identity). | Native namespacing via directories: `commands/<ns>/<cmd>.md` -> `/<ns>:<cmd>` | `/<ns>:<cmd>` for commands; `/skills <name>` for skills |

**Namespace grammar (`--namespace` input)**: dot-separated segments, each matching `[a-z][a-z0-9-]*`, max depth 3 (example: `orchestrator.project`). This is an installer input grammar, not a claim that every runtime supports dot identifiers at invocation time.

**Translation rule**:
- Runtimes with command namespace-by-path (Gemini, Qwen custom commands): dot segments map to nested directories and runtime-native `:` invocation.
- Runtimes with flat skill/subagent naming (Claude project/user skills, Codex, OpenCode, Qwen skills/subagents): installer must not synthesize namespaced skill/subagent identifiers.
- Runtime-owned namespace forms (example: Claude plugin `plugin:skill`) are preserved as runtime/plugin behavior, not generated by installer `--namespace`.

**Flat default**: When `--namespace` is omitted, installer writes flat paths for all runtimes. Runtime-native namespacing is only created when `--namespace` is explicitly provided and the selected runtime/profile supports it.

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
- Subagents path/model (relative path or config mode marker, or `""` if not supported)
- Prompts path/model (for runtimes where reusable prompts are a distinct capability, e.g., Codex custom prompts)
- Skills path (relative to install root, or `""` if not supported)
- Commands path (relative to install root)
- Hooks mode/path (`lifecycle-json`, `plugin-events`, `notify-callback`, or `""` if not supported)
- Scripts model (`embedded`, `inline-only`)
- Commands format (`md`, `toml`)
- Capability bitmask or flags: `supports_subagents`, `supports_commands`, `supports_skills`, `supports_hooks`, `supports_scripts`
- Policy context doc name (e.g., `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`)

**Sourcing mechanism**: `install.sh` sources `package/install/runtimes.sh` at the top of `main()` via `. "${PACKAGE_DIR}/install/runtimes.sh"`. No subshell — variables must be visible in the caller.

**No hardcoded paths outside registry**: Any function in `install.sh` that resolves a runtime path MUST read it from the registry arrays. Hardcoded path strings for runtime-specific locations are forbidden.

**Drift check**: `--check` compares resolved runtime paths against registry values.

---

### D-5: Frontmatter Transform Strategy

#### Minimal universal MD schema

Strip Claude-specific keys from SKILL.md when installing to non-Claude runtimes. Universal portable set: `name`, `description`. Claude-specific keys (`argument-hint`, `user-invocable`, `context`, `agent`) dropped at install time for all non-Claude targets. Commands mode: `$ARGUMENTS` → `{{args}}` for Qwen and Gemini.

#### Gemini TOML format conversion

Format-only transform: SKILL.md Markdown → Gemini `.toml`. Extracts `name` and `description` from frontmatter, places body as `prompt` TOML multiline string. Unknown keys pass through after minimal-schema normalization.

#### Per-runtime key map + TOML schema adjustments

Explicit `runtime × mode × key → action` rules beyond the minimal strip. Covers runtime-specific extensions (Codex invocation field, Gemini TOML structural requirements beyond basic format, OpenCode hooks binding).

**Official schema findings** (from docs research):
- Codex multi-agents: role-driven TOML schema (`[agents.<name>]` + optional `config_file`), not Markdown subagent files
- Codex hooks: documented as limited `notify` callback; no full lifecycle hook object model in official config docs
- Gemini commands: TOML with required `prompt`; `description` optional
- Gemini hooks: first-class `hooks` object in settings JSON with event-specific arrays and command handlers
- Qwen commands: Markdown preferred with optional `description`; TOML command format is deprecated
- Qwen skills/subagents: `SKILL.md` and agent Markdown frontmatter both require `name` + `description`
- Argument placeholders: `$ARGUMENTS` (Claude/Codex prompts) vs `{{args}}` (Gemini/Qwen command templates)

---

## Rationale

### Why per-runtime namespace semantics rather than a universal grammar?

A universal grammar would force one identifier model onto runtimes that do not share it. Current runtimes split into different models: directory-to-colon command namespace (Gemini, Qwen custom commands), runtime-owned plugin namespace (Claude `plugin:skill`), and flat skill/subagent identifiers (Codex, OpenCode, Claude project/user skills, Qwen skills/subagents). The installer therefore accepts one normalized input (`--namespace`) and translates only where a runtime has an official compatible namespace mechanism.

### Why embedded scripts rather than a standalone scripts install step?

Skill packages are self-contained units. A skill that ships helper scripts expects them to be co-located with the skill definition. Installing skills and scripts in separate passes creates a partial-install risk (skill without its scripts). Embedding them means the `copy_directory` function handles scripts automatically with no additional code path. For runtimes that only support inline scripts (Gemini), no directory is created — this is a capability difference already captured in the registry.

### Why `package/install/runtimes.sh` rather than a JSON or TOML registry?

The installer is a bash script. A bash-sourced file requires no additional tool dependencies (no `jq` needed for the registry itself, unlike settings.json merging). The registry is queried repeatedly during install; a bash-native data structure has zero parsing overhead. JSON was considered (consistent with settings.json pattern) but would require `jq` for every path lookup, adding fragility to the core install path. A separate `install/` subdirectory under `package/` keeps the registry co-located with the installer without polluting the package root.

---

## Alternatives Considered

### Alternative for D-2: Universal dot-notation grammar for all runtimes

Apply dot-notation uniformly (`<ns>.<name>`) to skills, subagents, and commands across all runtimes.

**Rejected**: No single runtime contract supports this across all artifact types. Gemini and Qwen command namespaces are directory-to-colon; OpenCode and Codex skill naming are flat; Claude plugin namespace uses `plugin:skill` and project/user skills are flat. Universal dot-notation would generate unsupported identifiers and break discovery/invocation.

### Alternative for D-2: Suppress namespace for all non-dot runtimes

Allow `--namespace` only for one naming style and skip translation for runtimes with other native models.

**Rejected**: Gemini and Qwen custom commands have first-class native namespace support (`/<ns>:<cmd>`). Skipping translation would throw away documented capability and produce inconsistent user experience.

### Alternative for D-3: Standalone scripts install step

Install a `scripts/` directory at the runtime root level, separate from skill packages (e.g., `.claude/scripts/` as a peer to `.claude/skills/`).

**Rejected**: No runtime has a documented standalone scripts root separate from skill/command packages. Installing to an undocumented path produces scripts that runtimes will not locate. Embedding within skill packages matches the documented runtime behavior for all five runtimes.

### Alternative for D-3: No scripts installation (document-only)

Do not install scripts at all; document that users must manage scripts manually.

**Rejected**: Hook scripts are functional requirements for Claude Code. Removing scripts installation would regress existing Claude Code functionality. Other runtimes' embedded scripts are needed for skills that invoke helper workflows.

### Alternative for D-4: JSON registry file

Store runtime metadata in `package/install/runtimes.json`, parsed via `jq` in `install.sh`.

**Rejected**: `jq` is required for settings.json merging but adds a hard dependency for path lookups if used for the registry. A bash-native registry has zero additional dependencies. The registry structure (associative arrays of strings) maps naturally to bash; no benefit from JSON encoding.

### Alternative for D-4: Inline constants in install.sh

Keep all path definitions as local variables or constants inside `install.sh` functions.

**Rejected**: Inline constants in a large installer script are not auditable, produce path-drift risk, and make additional runtimes expensive to add because core logic must be edited repeatedly.

---

## Consequences

### Positive

- Single registry eliminates path drift between installer logic and documented runtime paths
- Per-runtime capability flags allow unsupported-capability warnings without conditional logic scattered through install functions
- Flat default preserves existing flat installs without migration
- Per-runtime namespace translation gives correct native behavior for each supported namespace model (`:`, path scope, plugin namespace, flat identifiers)
- Runtimes without official skill/subagent namespace contracts remain installable without synthetic-name recognition failures
- Embedded scripts model requires no new install code paths

### Negative

- `package/install/runtimes.sh` adds a new sourced file that must be kept consistent with the research report matrix
- Per-runtime namespace translation logic is more complex than a single universal mapping
- Bash associative arrays require bash 4+; macOS ships bash 3.2 by default (mitigated: installer already uses bash 4 features; `brew install bash` is documented)

### Mitigations

- Drift detection and CI enforcement catch registry divergence
- Namespace translation is isolated in a pure function and independently testable
- macOS bash version constraint is an existing documented requirement, not introduced by this ADR

---

## Related

- [ADR-004](004-skill-agent-invocation-paths.md) — Skill-agent invocation paths (skill naming conventions that namespace builds on)
- [ADR-006](006-policy-modularization.md) — Policy modularization (policy-ref injection extended by D-1 for all 5 runtimes)
- [ADR-008](008-multi-provider-integration-strategy.md) — Multi-provider integration strategy (runtime capability matrix context)
- [ADR-013](013-extended-skills.md) — Extended skills (governance skills whose install behavior is governed by this ADR)
- `docs/knowledge/decisions/flat-skill-paths.md` — Flat vs dot-prefix skill paths decision record (D-2 builds on this)
- `reports/research/2026-02-19-multi-agent-install-plan.md` — Canonical install mapping matrix (maintained summary)
- `reports/research/2026-02-22-agent-capability-schema-deep-research.md` — Detailed capability + schema deep research (official docs + Context7 + DeepWiki)
