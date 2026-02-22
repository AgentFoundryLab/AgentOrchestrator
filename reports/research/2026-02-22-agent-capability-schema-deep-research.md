# Research: Multi-Agent Capability + Schema Deep Research

Date: 2026-02-22
Scope: Claude Code, Codex CLI, Gemini CLI, OpenCode, Qwen Code

## Method

This report cross-checks three source types per runtime:

1. Official vendor documentation (primary source of truth)
2. Context7 documentation snapshots
3. DeepWiki repository-grounded summaries

If official docs and secondary sources conflict, this report prefers official docs.

## Item 1: Capability Mapping (Subagents, Commands, Skills, Hooks, Scripts)

| Runtime | Subagents | Commands | Skills | Hooks | Scripts |
|---|---|---|---|---|---|
| Claude Code | Yes. `.claude/agents/*.md`, `~/.claude/agents/*.md`; YAML frontmatter + Markdown prompt body. | Yes. Custom slash commands are merged into skills; legacy `.claude/commands/*.md` remains compatible. | Yes. `.claude/skills/<name>/SKILL.md`, `~/.claude/skills/<name>/SKILL.md`. | Yes. Full lifecycle hook system in `settings.json` + hooks in skill/subagent frontmatter. | Yes. Skill folders may include `scripts/`; command hooks execute shell scripts. |
| Codex CLI | Yes (experimental multi-agent mode). Agent roles are configured in `[agents]` tables in `config.toml`; role configs loaded via `agents.<name>.config_file` TOML files. | Yes (deprecated user-defined command path). `~/.codex/prompts/*.md` custom prompts invoked as `/prompts:<name>`. | Yes. Agent Skills in `.agents/skills/*/SKILL.md`, `~/.agents/skills/*/SKILL.md` (+ admin/system scopes). | Limited. Official docs expose `notify` command callback after turn-complete; no generic event-hook map documented like Claude/Gemini/OpenCode. | Yes. Skills can bundle `scripts/`; custom prompts support argument expansion but are deprecated in favor of skills. |
| Gemini CLI | Partial/experimental. Official docs expose agent lifecycle + `agents.overrides`; file-based `.gemini/agents/*.md` paths are inferred from Context7/DeepWiki snapshots. | Yes. `.gemini/commands/**/*.toml`, `~/.gemini/commands/**/*.toml`; namespace via directories (`/ns:cmd`). | Yes. Agent Skills support (workspace/user/extensions). | Yes. `hooks` object in `.gemini/settings.json` / `~/.gemini/settings.json` with lifecycle + tool events. | Yes. Command templates support `!{...}` shell execution with confirmation; skills can include helper scripts (Agent Skills structure). |
| OpenCode | Yes. Primary and subagents (`mode: primary|subagent|all`) via `opencode.json(c)` and `.opencode/agents/*.md` / `~/.config/opencode/agents/*.md`. | Yes. JSON `command` config or Markdown files in `.opencode/commands/`, `~/.config/opencode/commands/`. | Yes. `.opencode/skills/*/SKILL.md`, `~/.config/opencode/skills/*/SKILL.md` (+ `.claude/skills`, `.agents/skills` compatibility). | Yes. Plugin event hook model via `.opencode/plugins/`, `~/.config/opencode/plugins/` and npm plugins. | Yes. Command shell injection (`!\`cmd\``), skill scripts, plugin/tool scripts. |
| Qwen Code | Yes. `.qwen/agents/*.md`, `~/.qwen/agents/*.md` (+ extension-provided agents). | Yes. `.qwen/commands/*.md` (recommended), TOML legacy/deprecated; directory namespaces map to `/ns:cmd`. | Yes (experimental feature flag in docs UI). `.qwen/skills/*/SKILL.md`, `~/.qwen/skills/*/SKILL.md` (+ extension skills). | No user-facing lifecycle hook framework documented in User Guide (unlike Claude/Gemini/OpenCode). | Yes. Custom commands support `!{...}` with confirmation; skills can include optional `scripts/` resources. |

## Item 2: Config Schema by Capability (Subagents, Prompts, Commands, Skills, Hooks, Tools)

## Claude Code

- Subagents:
  - Format: Markdown + YAML frontmatter
  - Paths: `.claude/agents/*.md`, `~/.claude/agents/*.md`
  - Key fields: `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`
- Prompts/Commands:
  - Format: Markdown with YAML frontmatter (via skills or legacy commands)
  - Paths: `.claude/skills/<name>/SKILL.md` (preferred), `.claude/commands/*.md` (compat)
- Skills:
  - Format: `SKILL.md` Markdown + YAML frontmatter
  - Common fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`
- Hooks:
  - Format: JSON in `settings.json`; also YAML hook blocks in skill/subagent frontmatter
  - Paths: `~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`
  - Types: `command`, `prompt`, `agent`
- Tools:
  - Format: JSON settings permissions (`allow`/`deny`/rule syntax), plus tool lists and permission modes

## Codex CLI

- Subagents (multi-agent roles):
  - Format: TOML in `config.toml`
  - Paths: `~/.codex/config.toml` and optional project `.codex/config.toml`
  - Key schema: `[agents.<name>]` with `description`, `config_file`; `agents.max_threads`; gated by `[features].multi_agent = true`
  - Role config files are TOML (example path pattern: `~/.codex/agents/<role>.toml` via `config_file`)
- Prompts:
  - Format: Markdown with frontmatter
  - Path: `~/.codex/prompts/*.md` (deprecated)
  - Metadata: `description`, `argument-hint`, placeholders `$1..$9`, `$ARGUMENTS`
- Commands:
  - Built-in slash commands in CLI; custom user commands are represented by deprecated custom prompts (`/prompts:<name>`)
- Skills:
  - Format: `SKILL.md` Markdown + YAML frontmatter (`name`, `description` required)
  - Paths: repo/user/admin/system skill scopes (`.agents/skills`, `~/.agents/skills`, `/etc/codex/skills`, system-bundled)
  - Optional skill metadata file: `agents/openai.yaml`
- Hooks:
  - No fully documented event hook map; official docs document `notify` command callback (`notify = [..]`) for `agent-turn-complete`
- Tools:
  - Format: TOML keys in `config.toml`
  - Core controls: `approval_policy`, `sandbox_mode`, `web_search`
  - External tools: `[mcp_servers.<id>]` tables

## Gemini CLI

- Subagents:
  - Officially documented baseline: agent system with `agents.overrides` in `settings.json`
  - Inferred (Context7/DeepWiki, medium confidence): Markdown + YAML frontmatter under `.gemini/agents/*.md`, `~/.gemini/agents/*.md`
  - Key fields: `name`, `description`, `kind`, `tools`, `model`
  - Enablement: `experimental.enableAgents` in settings
- Prompts/Commands:
  - Format: TOML custom command files
  - Paths: `.gemini/commands/**/*.toml`, `~/.gemini/commands/**/*.toml`
  - Key fields: `prompt` (required), `description` (optional)
  - Namespaces: directory nesting => `/<namespace>:<name>`
- Skills:
  - Format: Agent Skills `SKILL.md` structure
  - Paths: `.gemini/skills/`, `~/.gemini/skills/`, extensions `skills/`
- Hooks:
  - Format: JSON (`hooks` object in settings)
  - Paths: `.gemini/settings.json`, `~/.gemini/settings.json`, `/etc/gemini-cli/settings.json`
  - Hook entry schema includes `matcher`, `hooks[]`, and hook objects with `type: "command"`, `command`, optional `name`, `timeout`, `description`
- Tools:
  - Format: `settings.json` `tools.*`
  - Key fields: `tools.core`, `tools.allowed`, `tools.exclude`, `tools.discoveryCommand`, `tools.callCommand`, shell/sandbox settings

## OpenCode

- Subagents:
  - Format A: JSON/JSONC in `opencode.json(c)` via `agent` object with `mode`
  - Format B: Markdown + YAML frontmatter in agent files
  - Paths: `.opencode/agents/*.md`, `~/.config/opencode/agents/*.md`
  - Fields: `description` (required), `mode`, `model`, `prompt`, `tools`, `permission`, `hidden`, `temperature`
- Prompts/Commands:
  - Format A: JSON `command.<name>` (`template`, `description`, `agent`, `subtask`, `model`)
  - Format B: Markdown command files with YAML frontmatter + body template
  - Paths: `.opencode/commands/*.md`, `~/.config/opencode/commands/*.md`
- Skills:
  - Format: `SKILL.md` Markdown + YAML frontmatter
  - Paths: `.opencode/skills/*/SKILL.md`, `~/.config/opencode/skills/*/SKILL.md` (+ compat reads)
  - Recognized fields: `name`, `description` (required), `license`, `compatibility`, `metadata`
- Hooks:
  - Format: Plugin hook functions (JS/TS)
  - Paths: `.opencode/plugins/*`, `~/.config/opencode/plugins/*`, or npm plugins in config
- Tools:
  - Format: config JSON schema (`https://opencode.ai/config.json`)
  - Controls: `tools` (enable/disable), `permission` (allow/ask/deny), custom tools via plugin/tool modules

## Qwen Code

- Subagents:
  - Format: Markdown + YAML frontmatter
  - Paths: `.qwen/agents/*.md`, `~/.qwen/agents/*.md`, extension-provided `agents/`
  - Key fields: `name`, `description`, optional `tools`; body is system prompt
- Prompts/Commands:
  - Preferred format: Markdown command files with optional YAML `description`
  - Legacy/deprecated format: TOML (`prompt` required, `description` optional)
  - Paths: `.qwen/commands/`, `~/.qwen/commands/`, extension `commands/`
  - Parameter schema: `{{args}}`, shell injection `!{...}` (with confirmation)
- Skills:
  - Format: `SKILL.md` Markdown + YAML frontmatter
  - Paths: `.qwen/skills/*/SKILL.md`, `~/.qwen/skills/*/SKILL.md`, extension `skills/`
  - Validation: `name` and `description` non-empty
- Hooks:
  - User-facing hook configuration schema is not documented in current user docs
- Tools:
  - Format: `settings.json` under `tools.*`
  - Key fields: `tools.core`, `tools.allowed`, `tools.exclude`, `tools.approvalMode`, `tools.discoveryCommand`, `tools.callCommand`, sandbox/shell settings

## Installer Implications (High-Confidence)

1. Add explicit `subagents` capability dimension in runtime registry and docs.
2. Treat Codex subagents as TOML role configuration (not Markdown agent files).
3. Treat Gemini as supporting both Skills and Hooks (prior docs in repo claiming "no" are stale).
4. Keep Codex hooks marked as limited (`notify` callback), not full event lifecycle hooks.
5. Keep Qwen hooks marked unsupported for user-facing install artifacts until official user hook schema exists.

## Sources

### Official docs
- Claude Code subagents: https://docs.anthropic.com/en/docs/claude-code/sub-agents
- Claude Code skills/commands: https://docs.anthropic.com/en/docs/claude-code/skills
- Claude Code hooks: https://docs.anthropic.com/en/docs/claude-code/hooks
- Claude Code settings: https://docs.anthropic.com/en/docs/claude-code/settings
- Codex custom prompts: https://developers.openai.com/codex/custom-prompts
- Codex skills: https://developers.openai.com/codex/skills
- Codex config basics: https://developers.openai.com/codex/config-basic
- Codex config reference: https://developers.openai.com/codex/config-reference
- Codex multi-agents: https://developers.openai.com/codex/multi-agent
- Codex slash commands: https://developers.openai.com/codex/cli/slash-commands
- Gemini configuration: https://geminicli.com/docs/reference/configuration/
- Gemini hooks: https://geminicli.com/docs/hooks/
- Gemini commands: https://geminicli.com/docs/reference/commands/
- Gemini custom commands: https://geminicli.com/docs/cli/custom-commands/
- Gemini skills (official repo docs): https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/skills.md
- OpenCode config: https://opencode.ai/docs/config/
- OpenCode agents: https://opencode.ai/docs/agents/
- OpenCode commands: https://opencode.ai/docs/commands/
- OpenCode skills: https://opencode.ai/docs/skills/
- OpenCode plugins: https://opencode.ai/docs/plugins/
- OpenCode tools: https://opencode.ai/docs/tools/
- Qwen commands: https://qwenlm.github.io/qwen-code-docs/en/users/features/commands/
- Qwen skills: https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/
- Qwen subagents: https://qwenlm.github.io/qwen-code-docs/en/users/features/sub-agents/
- Qwen settings/tools: https://qwenlm.github.io/qwen-code-docs/en/users/configuration/settings/

### Context7
- Claude Code: `/anthropics/claude-code`
- Codex CLI: `/openai/codex`
- Gemini CLI: `/google-gemini/gemini-cli`
- OpenCode: `/sst/opencode`
- Qwen Code: `/qwenlm/qwen-code`

### DeepWiki
- Claude Code: https://deepwiki.com/search/what-capabilityconfig-artifact_8c7f1c3e-454b-4aa0-88f5-6fb638a83e03
- Codex: https://deepwiki.com/search/what-official-capabilityconfig_7b0295c7-6976-4c4a-a81f-536da99d5841
- Gemini CLI: https://deepwiki.com/search/what-capabilityconfig-artifact_cab14395-321c-4457-a6c2-2d11ea7954a6
- OpenCode: https://deepwiki.com/search/what-capabilityconfig-artifact_95b6cdca-b00a-4487-b9b5-2bf2af46958d
- Qwen Code: https://deepwiki.com/search/what-capabilityconfig-artifact_ad6a3ac2-ce21-43de-9b05-625ad05d87ce
