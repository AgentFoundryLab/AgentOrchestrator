# Research: Official Agent Capability Map for Installer v0.2 (Revalidated)

Date: 2026-02-22

## Scope

Runtimes:
- Claude Code
- Codex CLI
- Gemini CLI
- OpenCode
- Qwen Code

Capabilities (installer dimensions):
- `subagents`
- `commands`
- `skills`
- `hooks`
- `scripts`

Reference deep-research companion:
- `reports/research/2026-02-22-agent-capability-schema-deep-research.md`

## Capability Definitions

- `subagents`: runtime-native mechanism for specialized delegated agents (roles, agent files, or both).
- `commands`: user/project-defined slash-command artifacts loaded by the runtime.
- `skills`: SKILL-style reusable capability system.
- `hooks`: event/lifecycle interception mechanism that can run deterministic handlers.
- `scripts`: documented script execution support bundled in skills/commands/plugins/tools.

## Final Configuration Matrix (Authoritative)

| Agent | subagents | commands | skills | hooks | scripts |
|---|---|---|---|---|---|
| Claude Code | **Yes**. `.claude/agents/*.md`, `~/.claude/agents/*.md` (YAML + Markdown). | **Yes**. Preferred through skills (`.claude/skills/*/SKILL.md`), legacy `.claude/commands/*.md` remains compatible. | **Yes**. `.claude/skills/<name>/SKILL.md`, `~/.claude/skills/<name>/SKILL.md`. | **Yes**. Full lifecycle hooks in settings JSON + skill/subagent frontmatter hooks. | **Yes**. Skill `scripts/` and hook command scripts supported. |
| Codex CLI | **Yes (experimental)**. Multi-agent roles in `config.toml` (`[agents]`, `agents.<name>.config_file`). | **Yes (deprecated custom path)**. `~/.codex/prompts/*.md` invoked as `/prompts:<name>`. | **Yes**. `.agents/skills/*/SKILL.md`, `~/.agents/skills/*/SKILL.md` (+ admin/system). | **Limited**. `notify` callback command is documented; no full event-hook schema documented. | **Yes**. Skills may include `scripts/`; custom prompts deprecated in favor of skills. |
| Gemini CLI | **Partial/experimental**. Official docs expose agent lifecycle + `agents.overrides`; `.gemini/agents/*.md` paths come from Context7/DeepWiki snapshots. | **Yes**. `.gemini/commands/**/*.toml`, `~/.gemini/commands/**/*.toml`. | **Yes**. Agent Skills support (`.gemini/skills`, `~/.gemini/skills`, extensions). | **Yes**. `hooks` object in settings with lifecycle and tool events. | **Yes**. `!{...}` command shell execution + Agent Skills helper scripts. |
| OpenCode | **Yes**. Agent mode supports primary/subagent in JSON or Markdown agent files. | **Yes**. `.opencode/commands/*.md`, `~/.config/opencode/commands/*.md`, or `command` JSON config. | **Yes**. `.opencode/skills/*/SKILL.md`, `~/.config/opencode/skills/*/SKILL.md` (+ compat reads). | **Yes**. Plugin event hooks (`.opencode/plugins/`, `~/.config/opencode/plugins/`, npm plugins). | **Yes**. Command shell injection + skill scripts + plugin/tool scripts. |
| Qwen Code | **Yes**. `.qwen/agents/*.md`, `~/.qwen/agents/*.md` (+ extension agents). | **Yes**. Markdown commands preferred in `.qwen/commands/`; TOML legacy/deprecated. | **Yes (experimental)**. `.qwen/skills/*/SKILL.md`, `~/.qwen/skills/*/SKILL.md` (+ extension skills). | **No user-facing hook schema documented**. | **Yes**. `!{...}` custom command execution + optional skill scripts/resources. |

## Installer v0.2 Target Mapping

1. `claude`
- subagents: `.claude/agents/*.md` (project), `~/.claude/agents/*.md` (global)
- commands: `.claude/skills/<cmd>/SKILL.md` (preferred), `.claude/commands/*.md` (compat)
- skills: `.claude/skills/<name>/SKILL.md`
- hooks: settings JSON hierarchy + frontmatter hook scopes
- scripts: supported (embedded)

2. `codex`
- subagents: `[agents]` and `agents.<name>.config_file` in `~/.codex/config.toml` / `.codex/config.toml`
- commands: `~/.codex/prompts/*.md` (deprecated compatibility path)
- skills: `.agents/skills/<name>/SKILL.md` (project), `~/.agents/skills/<name>/SKILL.md` (user)
- hooks: limited to documented `notify` callback
- scripts: supported via skills

3. `gemini`
- subagents: official baseline uses `agents.overrides` in settings; file-path installs for `.gemini/agents/*.md` should be treated experimental/inferred
- commands: `.gemini/commands/**/*.toml` (project/user)
- skills: `.gemini/skills/*/SKILL.md`, `~/.gemini/skills/*/SKILL.md`
- hooks: settings `hooks` JSON
- scripts: supported (`!{...}` and skill helpers)

4. `opencode`
- subagents: `.opencode/agents/*.md` / `~/.config/opencode/agents/*.md` and `agent` config objects
- commands: `.opencode/commands/*.md`, `~/.config/opencode/commands/*.md`, or `command` in JSON config
- skills: `.opencode/skills/*/SKILL.md` (+ `.claude/skills`, `.agents/skills` compatibility)
- hooks: plugin event system
- scripts: supported

5. `qwen`
- subagents: `.qwen/agents/*.md` (project), `~/.qwen/agents/*.md` (user)
- commands: `.qwen/commands/*.md` preferred; TOML legacy/deprecated
- skills: `.qwen/skills/*/SKILL.md`
- hooks: not documented as user-installable lifecycle hooks
- scripts: supported (`!{...}` + skill resources)

## Notes for Implementation

- Add `subagents` as a first-class runtime capability in installer registry/check output.
- Keep Codex custom prompts as compatibility mode; prioritize Codex skills for net-new installs.
- Treat Codex hooks as limited (`notify` callback), not equivalent to Claude/Gemini/OpenCode lifecycle hooks.
- Treat Gemini hooks and skills as supported (previous "not supported" assumptions are stale).
- Treat Qwen hooks as unsupported until official user-facing hook schema is published.
- Scripts are not hooks; scripts are executable resources and tool payloads.

## Current Implementation Gap (Verified 2026-02-22)

- `tests/install/smoke.sh` conformance currently asserts Gemini as commands-only (`no skills`, `no hooks`), which conflicts with the revalidated runtime capability baseline in this report.
- Current CI pass therefore validates installer behavior against an older matrix, not this updated capability map.
- Follow-up required: update runtime registry semantics/tests before treating this report as fully implemented behavior.

## Official Sources

Claude Code:
- Subagents: https://docs.anthropic.com/en/docs/claude-code/sub-agents
- Skills/commands: https://docs.anthropic.com/en/docs/claude-code/skills
- Hooks: https://docs.anthropic.com/en/docs/claude-code/hooks
- Settings: https://docs.anthropic.com/en/docs/claude-code/settings

Codex CLI:
- Multi-agents: https://developers.openai.com/codex/multi-agent
- Config basics: https://developers.openai.com/codex/config-basic
- Config reference: https://developers.openai.com/codex/config-reference
- Custom prompts (deprecated): https://developers.openai.com/codex/custom-prompts
- Skills: https://developers.openai.com/codex/skills

Gemini CLI:
- Configuration: https://geminicli.com/docs/reference/configuration/
- Hooks: https://geminicli.com/docs/hooks/
- Commands: https://geminicli.com/docs/reference/commands/
- Custom commands: https://geminicli.com/docs/cli/custom-commands/
- Skills (official repo docs): https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/skills.md

OpenCode:
- Config: https://opencode.ai/docs/config/
- Agents: https://opencode.ai/docs/agents/
- Commands: https://opencode.ai/docs/commands/
- Skills: https://opencode.ai/docs/skills/
- Plugins: https://opencode.ai/docs/plugins/
- Tools: https://opencode.ai/docs/tools/

Qwen Code:
- Commands: https://qwenlm.github.io/qwen-code-docs/en/users/features/commands/
- Skills: https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/
- Subagents: https://qwenlm.github.io/qwen-code-docs/en/users/features/sub-agents/
- Settings/tools: https://qwenlm.github.io/qwen-code-docs/en/users/configuration/settings/
