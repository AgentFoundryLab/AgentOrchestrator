# Research: Official Agent Capability Map for Installer v0.1.1

Date: 2026-02-20

## Scope

This report is based on **official documentation for each runtime**

Agents covered:
- Claude Code
- Codex CLI
- Gemini CLI
- OpenCode
- Qwen Code

Capabilities covered:
- `commands`
- `skills`
- `hooks`
- `scripts`

## Capability Definitions (for installer mapping)

- `commands`: user/project-defined slash-command artifacts the runtime loads from filesystem/config.
- `skills`: native SKILL-style reusable capability system.
- `hooks`: native event-driven hook mechanism (pre/post tool/session/etc).
- `scripts`: documented ability to execute shell/script content from command/skill/plugin flows.

## Final Intended Configuration Matrix (authoritative target)

| Agent | commands | skills | hooks | scripts |
|---|---|---|---|---|
| Claude Code | **Yes**. Canonical: `.claude/skills/<name>/SKILL.md` (commands now merged into skills). Legacy `.claude/commands/*.md` still works for compatibility. | **Yes**. Project: `.claude/skills/<name>/SKILL.md`; User: `~/.claude/skills/<name>/SKILL.md`. | **Yes**. Configure in `~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`, plus plugin/skill/agent contexts. | **Yes**. Skills can include supporting `scripts/` and execute script workflows. |
| Codex CLI | **Yes (deprecated path model)**. Custom prompts via `~/.codex/prompts/*.md`, invoked as `/prompts:<name>`; explicit invocation only. | **Yes (preferred)**. Repo/user/admin/system skill locations; repo-standard `.agents/skills/<name>/SKILL.md` and user `~/.agents/skills/<name>/SKILL.md`. | **No native general hook framework documented**. (Only notification command config, not full event hooks.) | **Yes**. Skills support optional `scripts/` content in skill packages. |
| Gemini CLI | **Yes**. User: `~/.gemini/commands/*.toml`; Project: `.gemini/commands/*.toml`; namespaced by subdirectories. | **No native SKILL.md system documented**. | **No native event-hook framework documented**. | **Yes**. Commands support `!{...}` shell execution with escaping + confirmation. |
| OpenCode | **Yes**. Project: `.opencode/commands/*.md`; Global: `~/.config/opencode/commands/*.md` (or `opencode.json` `command` config). | **Yes**. Project: `.opencode/skills/<name>/SKILL.md`; Global: `~/.config/opencode/skills/<name>/SKILL.md` (also reads `.claude/skills` and `.agents/skills`). | **Yes** via plugin events. Plugin dirs: `.opencode/plugins/`, `~/.config/opencode/plugins/`; event subscriptions supported. | **Yes**. Commands support shell output injection (`!\`command\``); plugins/scripts in JS/TS supported. |
| Qwen Code | **Yes**. User: `~/.qwen/commands/`; Project: `.qwen/commands/`; Markdown recommended, TOML deprecated. | **Yes**. User: `~/.qwen/skills/<name>/SKILL.md`; Project: `.qwen/skills/<name>/SKILL.md`. | **No native event-hook framework documented**. | **Yes**. Commands support `!{command}` with confirmation; skills may include optional `scripts/` helpers. |

## Installer v0.1.1 Target Mapping

Use this as the installer source-of-truth:

1. `claude`
- commands: `.claude/skills/<cmd>/SKILL.md` (preferred)
- compatibility read path: `.claude/commands/*.md`
- skills: `.claude/skills/<name>/SKILL.md`
- hooks: Claude settings JSON hierarchy
- scripts: supported

2. `codex`
- commands: `~/.codex/prompts/*.md` (deprecated upstream; keep for compatibility only)
- skills: `.agents/skills/<name>/SKILL.md` (project), `~/.agents/skills/<name>/SKILL.md` (user)
- hooks: not supported as native event hooks
- scripts: supported via skills

3. `gemini`
- commands: `.gemini/commands/*.toml` (project), `~/.gemini/commands/*.toml` (user)
- skills: not supported
- hooks: not supported
- scripts: supported via `!{...}`

4. `opencode`
- commands: `.opencode/commands/*.md` (project), `~/.config/opencode/commands/*.md` (user)
- skills: `.opencode/skills/<name>/SKILL.md` + compatible reads from `.claude/skills` and `.agents/skills`
- hooks: plugin event system (`.opencode/plugins/`, `~/.config/opencode/plugins/`)
- scripts: supported

5. `qwen`
- commands: `.qwen/commands/*.md` (preferred), TOML legacy support
- skills: `.qwen/skills/<name>/SKILL.md`
- hooks: not supported
- scripts: supported (`!{...}` and skill helper scripts)

## Notes for Implementation

- Treat `Codex custom prompts` as compatibility mode; prioritize Codex skills for new installs.
- Treat `Claude commands` as compatibility mode; prioritize Claude skills for new installs.
- Do not advertise hooks for Gemini/Codex/Qwen unless official docs add native event hooks.
- OpenCode hooks should be modeled as **plugin event hooks**, not command hooks.

---

## Cross-Reference: spec-kit Implementation

**Source**: `/workspace/spec-kit/src/specify_cli/extensions.py` — `CommandRegistrar` class

spec-kit is a production multi-agent installer covering 16+ runtimes. Its approach is the reference implementation for frontmatter transforms and command format mapping.

### Command Format by Runtime (spec-kit AGENT_CONFIGS)

| Agent | Directory | Format | Args Placeholder |
|-------|-----------|--------|-----------------|
| Claude Code | `.claude/commands/` | MD | `$ARGUMENTS` |
| Gemini CLI | `.gemini/commands/` | **TOML** | `{{args}}` |
| Qwen Code | `.qwen/commands/` | **TOML** | `{{args}}` |
| opencode | `.opencode/command/` | MD | `$ARGUMENTS` |
| GitHub Copilot | `.github/agents/` | MD | `$ARGUMENTS` |
| Cursor | `.cursor/commands/` | MD | `$ARGUMENTS` |
| Windsurf | `.windsurf/workflows/` | MD | `$ARGUMENTS` |
| Amazon Q | `.amazonq/prompts/` | MD | `$ARGUMENTS` |
| Amp | `.agents/commands/` | MD | `$ARGUMENTS` |

**Qwen format — resolved**: Official Qwen docs (updated 2026-02-11) confirm commands use **Markdown** (`.md`). TOML is deprecated, triggers an automatic migration prompt, and will be removed in a future version. spec-kit installing Qwen commands as TOML is incorrect. `RUNTIME_DOC_FORMAT[qwen]="markdown"` is right.

### Frontmatter Transform Strategy (spec-kit)

spec-kit uses a **universal minimal source format** with runtime-specific rendering at install time:

**Universal source frontmatter:**
```yaml
---
description: string          # Required
tools: [string]              # Optional, MCP tools
scripts:
  sh: string                 # Bash script path
  ps: string                 # PowerShell script path
---
```

**Transform pipeline (`CommandRegistrar`):**
1. Parse universal YAML frontmatter from source Markdown
2. Adjust script paths (extension-relative → repo-relative)
3. Render: Markdown path or TOML path based on `AGENT_CONFIGS[agent].format`
   - TOML: `description` + body as `prompt = """..."""`; drop all other keys
   - MD: YAML frontmatter preserved; inject extension context comment
4. Convert argument placeholder: `$ARGUMENTS` → `{{args}}` for TOML agents

**Note on argument placeholders (official docs)**:
- Qwen commands use `{{args}}` (confirmed in official Qwen docs) — not `$ARGUMENTS`
- Gemini commands also use `{{args}}` per spec-kit; verify against official Gemini docs
- Claude uses `$ARGUMENTS`

This placeholder difference is a transform concern for T-094 (G-003), separate from the format (MD/TOML) question.

**Key design principle**: Source frontmatter is minimal and universal. Claude-specific keys (`argument-hint`, `user-invocable`) do not exist in spec-kit's source format — they would be agent-specific extensions, not part of the universal schema.

### Implication for G-003 (frontmatter schema gap)

The AgentOrchestrator SKILL.md schema uses Claude-specific keys (`argument-hint`, `user-invocable`) that have no equivalent in other runtimes. Two resolution approaches from spec-kit's design:

1. **Minimal universal schema**: Strip all Claude-specific keys when installing to non-Claude runtimes. `description` is the only reliably portable field.
2. **Per-runtime key mapping**: Define explicit drop/keep/rename rules per runtime (more expressive but more complex to maintain).

spec-kit uses approach 1 (minimal). T-094 should evaluate both and decide.

## Official Sources

Claude Code:
- Skills / commands convergence: https://code.claude.com/docs/en/slash-commands
- Hooks reference: https://code.claude.com/docs/en/hooks

Codex CLI:
- Custom prompts (deprecated): https://developers.openai.com/codex/custom-prompts
- Skills: https://developers.openai.com/codex/skills
- Config reference (`notify`): https://developers.openai.com/codex/config-reference

Gemini CLI:
- Custom commands: https://google-gemini.github.io/gemini-cli/docs/cli/custom-commands.html
- CLI docs index: https://google-gemini.github.io/gemini-cli/docs/cli/

OpenCode:
- Commands: https://opencode.ai/docs/commands/
- Agent skills: https://opencode.ai/docs/skills/
- Plugins (event hooks): https://opencode.ai/docs/plugins/

Qwen Code:
- Commands: https://qwenlm.github.io/qwen-code-docs/en/users/features/commands/
- Skills: https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/
- Subagents: https://qwenlm.github.io/qwen-code-docs/en/users/features/sub-agents/
