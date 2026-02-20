# Research: spec-kit Multi-Agent Support and Installer Upgrade Plan

Date: 2026-02-20

## Scope

- Inspect local `/workspace/spec-kit` codebase (latest pulled state).
- Explain how spec-kit supports multiple agents.
- Explain how spec-kit differentiates commands vs skills vs extensions.
- Update install plan for Claude, Codex, Gemini, OpenCode, QwenCode.
- Provide capability matrix for: sub-agents, roles, commands, skills, hooks, scripts.

## Hard truths (verified)

1. spec-kit is multi-agent for **command-packaging and command conversion**, not a full sub-agent role orchestration framework.
2. Current head adds a real **extensions system** (`src/specify_cli/extensions.py`) with extension manifests, command registration, and extension hooks.
3. There is still major path drift:
   - core release packager uses Codex `.codex/prompts`
   - extension command registrar has **no Codex entry** at all
   - core `--ai-skills` logic has Codex/OpenCode/Gemini/Qwen fallback dependencies that are fragile.

## How spec-kit differentiates Commands vs Skills vs Extensions

## 1) Commands (core slash-command files)

What they are:
- Agent-specific slash command files generated from `templates/commands/*.md`.

Where they come from:
- `.github/workflows/scripts/create-release-packages.sh` / `.ps1`.
- `generate_commands()` converts frontmatter/body + placeholders for each agent format.

Key behavior:
- Commands are generated per runtime path/format.
- Scripts from frontmatter (`scripts:` and optional `agent_scripts:`) are inlined into command bodies.

References:
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:40`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:160`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.ps1:267`

## 2) Skills (`--ai-skills` conversion)

What they are:
- Agent skill folders containing `SKILL.md` built from command template content.

Where they come from:
- `install_ai_skills()` in `src/specify_cli/__init__.py`.
- It parses command markdown and writes Agentskills-style metadata + content into per-agent skills dirs.

Key behavior:
- Triggered by `specify init ... --ai-skills`.
- Uses override map for skills dir (Codex currently overridden to `.agents/skills`).
- Installs additively (does not overwrite existing SKILL.md).

References:
- `/workspace/spec-kit/src/specify_cli/__init__.py:991`
- `/workspace/spec-kit/src/specify_cli/__init__.py:1014`
- `/workspace/spec-kit/src/specify_cli/__init__.py:1032`
- `/workspace/spec-kit/src/specify_cli/__init__.py:1200`

## 3) Extensions (modular plugin packages)

What they are:
- Installable packages under `.specify/extensions/<ext-id>/` with `extension.yml`.
- Must declare `provides.commands`; may declare `hooks` and config defaults.

Where they come from:
- `src/specify_cli/extensions.py` (`ExtensionManifest`, `ExtensionManager`, `CommandRegistrar`, `HookExecutor`, `ConfigManager`).

Key behavior:
- `specify extension install` installs extension package.
- Command registrar writes extension commands into detected agent command dirs.
- Hook executor registers/unregisters extension hooks in `.specify/extensions.yml`.

References:
- `/workspace/spec-kit/src/specify_cli/extensions.py:39`
- `/workspace/spec-kit/src/specify_cli/extensions.py:108`
- `/workspace/spec-kit/src/specify_cli/extensions.py:305`
- `/workspace/spec-kit/src/specify_cli/extensions.py:579`
- `/workspace/spec-kit/src/specify_cli/extensions.py:1409`

## Multi-agent support (current state)

## Core AI registry (init/check)

- `AGENT_CONFIG` contains `claude`, `gemini`, `qwen`, `opencode`, `codex` plus others.
- `specify init --ai` validates selection from this map.

References:
- `/workspace/spec-kit/src/specify_cli/__init__.py:127`
- `/workspace/spec-kit/src/specify_cli/__init__.py:1298`

## Core command output mapping (release packager)

For requested runtimes:
- Claude: `.claude/commands` (md)
- Gemini: `.gemini/commands` (toml)
- Qwen: `.qwen/commands` (toml)
- OpenCode: `.opencode/command` (md)
- Codex: `.codex/prompts` (md)

References:
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:161`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:165`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:181`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:185`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:191`

## Extension command mapping (different system)

`CommandRegistrar.AGENT_CONFIGS` currently includes Claude/Gemini/Qwen/OpenCode etc, but **does not include Codex**.

References:
- `/workspace/spec-kit/src/specify_cli/extensions.py:583`
- `/workspace/spec-kit/src/specify_cli/extensions.py:614`
- `/workspace/spec-kit/src/specify_cli/extensions.py:833`

## Capability matrix (requested runtimes)

Legend:
- `Yes` = implemented and mapped for runtime.
- `Partial` = capability exists but mapping/path is inconsistent or fragile.
- `No` = not implemented as a runtime capability.

| Runtime | Sub-agents | Roles | Commands | Skills | Hooks | Scripts |
|---|---|---|---|---|---|---|
| Claude | No | No | Yes | Yes | Partial | Yes |
| Codex | No | No | Yes | Partial | Partial | Yes |
| Gemini | No | No | Yes | Partial | Partial | Yes |
| OpenCode | No | No | Yes | Partial | Partial | Yes |
| QwenCode | No | No | Yes | Partial | Partial | Yes |

Interpretation:
- Sub-agents/Roles: no spec-kit runtime orchestration layer for these.
- Commands: yes via packager.
- Skills: system exists, but non-Claude paths rely on fallback behavior that may fail depending on packaging/layout.
- Hooks: extension hook system exists globally, but runtime integration depends on extension and agent behavior.
- Scripts: yes, command templates embed shell/PowerShell scripts.

## Codex path drift (specific)

Drift in current spec-kit head:

1. Core command packager writes Codex commands to `.codex/prompts`.
   - `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh:191`

2. Extension command registrar has no Codex mapping in `AGENT_CONFIGS`.
   - `/workspace/spec-kit/src/specify_cli/extensions.py:583`

3. Core skills installer has Codex skills override to `.agents/skills`, not `.codex/skills`.
   - `/workspace/spec-kit/src/specify_cli/__init__.py:993`

This means Codex command handling is split across multiple models and currently inconsistent.

## Official Codex docs check (for path truth)

From official OpenAI Codex custom prompts docs:
- Project prompts default to `<project>/.codex/prompts` (with `<project>/prompts` fallback).
- Global prompts default to `~/.codex/prompts`.
- Docs also note custom prompts are beta and subject to change.

Primary sources:
- https://developers.openai.com/codex/custom-prompts
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/cli/agents-md

Corroboration in official `openai/codex` source:
- default prompts dir helper resolves `$CODEX_HOME/prompts`
- custom prompt discovery reads `.md` files from prompt dirs

References:
- `/tmp/openai-codex/codex-rs/core/src/custom_prompts.rs:7`
- `/tmp/openai-codex/codex-rs/core/src/custom_prompts.rs:42`

## Installer update plan for `/workspace/orchestrator`

## Phase 1: Split capability profiles cleanly

1. Keep **core commands install** profile per runtime path.
2. Add separate **skills install** profile (opt-in) and explicit caveats for fragile mappings.
3. Add separate **extensions install** profile (if/when extension artifacts are provided).

## Phase 2: Canonical runtime mapping table in installer

Define one source map in installer constants for:
- command dir
- command format/extension
- skills dir
- context file target
- supports extensions command registration

Initial mapping recommendation:
- Claude: commands `.claude/commands`, skills `.claude/skills`
- Codex: commands `.codex/prompts`, skills `.agents/skills`
- Gemini: commands `.gemini/commands`, skills `.gemini/skills`
- OpenCode: commands `.opencode/command`, skills `.opencode/skills`
- Qwen: commands `.qwen/commands`, skills `.qwen/skills`

## Phase 3: Explicit drift checks in CI

Fail when incompatible paths are detected across:
- core packager mapping
- extension registrar mapping
- installer mapping/docs

Minimum check examples:
- codex present in all registries where extension commands are claimed
- no singular/plural command-dir mismatch (`command` vs `commands`) without explicit adapter
- skills path present and consistent with runtime profile

## Phase 4: Safe rollout

1. Ship commands support first for all five runtimes.
2. Gate skills and extensions behind explicit flags until path drift is resolved.
3. Print runtime capability warnings during install if a selected capability is partial.

## Blockers

1. Codex missing from extension registrar config (`extensions.py`) blocks Codex extension-command parity.
2. `--ai-skills` non-Claude behavior depends on fallback templates; this is not robust without packaging guarantees.
3. Multiple command-dir conventions (`.codex/prompts`, `.opencode/command`, `.qwen/commands`) require strict per-runtime mapping and tests.

## Source references

Local spec-kit:
- `/workspace/spec-kit/src/specify_cli/__init__.py`
- `/workspace/spec-kit/src/specify_cli/extensions.py`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.sh`
- `/workspace/spec-kit/.github/workflows/scripts/create-release-packages.ps1`
- `/workspace/spec-kit/scripts/bash/update-agent-context.sh`
- `/workspace/spec-kit/scripts/powershell/update-agent-context.ps1`

Official Codex docs/source:
- https://developers.openai.com/codex/custom-prompts
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/cli/agents-md
- `/tmp/openai-codex/codex-rs/core/src/custom_prompts.rs`
