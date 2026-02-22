# Agent Capability Report

Date: 2026-02-22  
Scope: Claude Code, Codex CLI, Gemini CLI, OpenCode, Qwen Code  
Status: Canonical consolidated report (replaces two prior research drafts)

## Purpose

Provide one clean, implementation-oriented reference for runtime capabilities and artifact schemas used by the multi-agent installer.

## Inputs Consolidated

- Prior install-policy summary draft (dated 2026-02-19)
- Prior capability/schema deep-research draft (dated 2026-02-22)

## Method and Confidence

Source priority:
1. Official runtime/vendor documentation (primary)
2. Context7 snapshots (secondary)
3. DeepWiki repository-grounded summaries (secondary)

Conflict policy:
- When sources conflict, official docs take precedence.
- Any unsupported or inferred behavior is marked explicitly.

## Capability Definitions

- `subagents`: Runtime-native mechanism for delegated/specialized agents.
- `commands`: User/project-defined slash command artifacts.
- `skills`: Reusable SKILL-style capability packs.
- `hooks`: Event/lifecycle interception handlers.
- `scripts`: Executable helper payloads in skills/commands/plugins/tools.

## Authoritative Capability Matrix

| Runtime | Subagents | Commands | Skills | Hooks | Scripts |
|---|---|---|---|---|---|
| Claude Code | Yes | Yes | Yes | Yes | Yes |
| Codex CLI | Yes (experimental) | Yes (deprecated custom path) | Yes | Limited (`notify` callback) | Yes |
| Gemini CLI | Partial/experimental agent-file pathing; official agent lifecycle support | Yes | Yes | Yes | Yes |
| OpenCode | Yes | Yes | Yes | Yes (plugin events) | Yes |
| Qwen Code | Yes | Yes | Yes (experimental) | No documented user-facing lifecycle hook schema | Yes |

## Runtime Schema Summary

### Claude Code

- Subagents:
  - `.claude/agents/*.md`, `~/.claude/agents/*.md`
  - Markdown + YAML frontmatter
  - Common fields: `name`, `description`, `tools`, `model`, `hooks`, `skills`
- Commands:
  - Preferred via skills (`.claude/skills/<name>/SKILL.md`)
  - Legacy compatibility: `.claude/commands/*.md`
- Skills:
  - `.claude/skills/<name>/SKILL.md`, `~/.claude/skills/<name>/SKILL.md`
  - Markdown + YAML frontmatter
- Hooks:
  - `settings.json` hook config and skill/subagent frontmatter hook blocks
  - Paths include `~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`
- Tools:
  - Settings permissions (`allow`/`deny`/rules), tool lists, permission mode controls

### Codex CLI

- Subagents:
  - `config.toml` role tables (`[agents.<name>]`) with `config_file`
  - Optional project `.codex/config.toml`; user `~/.codex/config.toml`
  - Experimental multi-agent feature
- Commands:
  - Custom prompts path: `~/.codex/prompts/*.md`
  - Invoked as `/prompts:<name>` (deprecated path)
- Skills:
  - `.agents/skills/*/SKILL.md`, `~/.agents/skills/*/SKILL.md`
  - Optional admin/system scopes
- Hooks:
  - Limited documented callback: `notify` after agent turn completion
  - No full lifecycle event-hook map documented
- Tools:
  - TOML config controls including `approval_policy`, `sandbox_mode`, MCP servers

### Gemini CLI

- Subagents:
  - Official baseline: agent lifecycle plus `agents.overrides` in settings
  - `.gemini/agents/*.md` pathing remains inferred/secondary-source-backed
- Commands:
  - `.gemini/commands/**/*.toml`, `~/.gemini/commands/**/*.toml`
  - Directory nesting maps to command namespaces
- Skills:
  - `.gemini/skills/`, `~/.gemini/skills/`, extension skill directories
- Hooks:
  - `hooks` object in settings JSON
  - Paths: `.gemini/settings.json`, `~/.gemini/settings.json`, `/etc/gemini-cli/settings.json`
- Tools:
  - `tools.*` settings for core/allowed/excluded tools and tool call/discovery commands

### OpenCode

- Subagents:
  - Config object (`agent`) in `opencode.json(c)` and/or Markdown agent files
  - `.opencode/agents/*.md`, `~/.config/opencode/agents/*.md`
- Commands:
  - JSON command config (`command.<name>`) and/or Markdown command files
  - `.opencode/commands/*.md`, `~/.config/opencode/commands/*.md`
- Skills:
  - `.opencode/skills/*/SKILL.md`, `~/.config/opencode/skills/*/SKILL.md`
  - Compatibility reads from `.claude/skills` and `.agents/skills`
- Hooks:
  - Plugin event hook model via local/user plugin directories or npm plugins
- Tools:
  - Config schema controls for tools and permission model

### Qwen Code

- Subagents:
  - `.qwen/agents/*.md`, `~/.qwen/agents/*.md`, extension-provided agents
  - Markdown + YAML frontmatter
- Commands:
  - Preferred: Markdown in `.qwen/commands/` and `~/.qwen/commands/`
  - Legacy/deprecated: TOML command format
- Skills:
  - `.qwen/skills/*/SKILL.md`, `~/.qwen/skills/*/SKILL.md`, extension skills
  - Experimental feature in current docs
- Hooks:
  - No documented user-facing lifecycle hook configuration schema
- Tools:
  - `settings.json` with `tools.*`, approval, sandbox, and shell controls

## Installer v0.2 Policy Mapping

1. Add `subagents` as a first-class capability dimension in runtime registry and reporting.
2. Keep Codex prompts as compatibility mode; prefer skills for new installs.
3. Treat Codex hooks as limited (`notify`) rather than equivalent to full lifecycle hook runtimes.
4. Treat Gemini as supporting both skills and hooks; old commands-only assumptions are stale.
5. Treat Qwen hooks as unsupported until official user-facing schema is published.
6. Keep `scripts` separate from `hooks` in capability and install logic.

## Verified Implementation Gap (2026-02-22)

- `tests/install/smoke.sh` still encodes older Gemini assumptions (commands-only).
- Current CI passing state can validate against older behavior, not this updated capability baseline.
- Follow-up is required to align installer runtime registry/tests with this report.

## Sources

### Official docs

- Claude Code:
  - https://docs.anthropic.com/en/docs/claude-code/sub-agents
  - https://docs.anthropic.com/en/docs/claude-code/skills
  - https://docs.anthropic.com/en/docs/claude-code/hooks
  - https://docs.anthropic.com/en/docs/claude-code/settings
- Codex CLI:
  - https://developers.openai.com/codex/multi-agent
  - https://developers.openai.com/codex/config-basic
  - https://developers.openai.com/codex/config-reference
  - https://developers.openai.com/codex/custom-prompts
  - https://developers.openai.com/codex/skills
  - https://developers.openai.com/codex/cli/slash-commands
- Gemini CLI:
  - https://geminicli.com/docs/reference/configuration/
  - https://geminicli.com/docs/hooks/
  - https://geminicli.com/docs/reference/commands/
  - https://geminicli.com/docs/cli/custom-commands/
  - https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/skills.md
- OpenCode:
  - https://opencode.ai/docs/config/
  - https://opencode.ai/docs/agents/
  - https://opencode.ai/docs/commands/
  - https://opencode.ai/docs/skills/
  - https://opencode.ai/docs/plugins/
  - https://opencode.ai/docs/tools/
- Qwen Code:
  - https://qwenlm.github.io/qwen-code-docs/en/users/features/commands/
  - https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/
  - https://qwenlm.github.io/qwen-code-docs/en/users/features/sub-agents/
  - https://qwenlm.github.io/qwen-code-docs/en/users/configuration/settings/

### Secondary evidence used for cross-checking

- Context7 libraries:
  - `/anthropics/claude-code`
  - `/openai/codex`
  - `/google-gemini/gemini-cli`
  - `/sst/opencode`
  - `/qwenlm/qwen-code`
- DeepWiki queries:
  - https://deepwiki.com/search/what-capabilityconfig-artifact_8c7f1c3e-454b-4aa0-88f5-6fb638a83e03
  - https://deepwiki.com/search/what-official-capabilityconfig_7b0295c7-6976-4c4a-a81f-536da99d5841
  - https://deepwiki.com/search/what-capabilityconfig-artifact_cab14395-321c-4457-a6c2-2d11ea7954a6
  - https://deepwiki.com/search/what-capabilityconfig-artifact_95b6cdca-b00a-4487-b9b5-2bf2af46958d
  - https://deepwiki.com/search/what-capabilityconfig-artifact_ad6a3ac2-ce21-43de-9b05-625ad05d87ce
