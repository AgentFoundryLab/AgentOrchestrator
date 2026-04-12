# Agent Capability Analysis

Date: 2026-02-22 (updated 2026-02-25)
Scope: Claude Code, Codex CLI, Gemini CLI, OpenCode, Qwen Code
Status: Canonical consolidated report (replaces two prior research drafts)
Update: Added sub-agent file format schemas and config settings for Claude agent teams, Codex multi-agent roles, and Gemini sub-agents; clarified official Codex/Gemini skills schemas from primary docs.

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
| Claude Code | Yes + Agent Teams (experimental) | Yes | Yes | Yes | Yes |
| Codex CLI | Yes (experimental, `multi_agent = true`) | Yes (deprecated custom path) | Yes | Limited (`notify` callback) | Yes |
| Gemini CLI | Yes (experimental, `experimental.enableAgents: true`; `~/.gemini/agents/*.md` confirmed primary source) | Yes | Yes | Yes | Yes |
| OpenCode | Yes | Yes | Yes | Yes (plugin events) | Yes |
| Qwen Code | Yes | Yes | Yes (experimental) | No documented user-facing lifecycle hook schema | Yes |

## Runtime Schema Summary

### Claude Code

- Subagents:
  - `.claude/agents/*.md`, `~/.claude/agents/*.md`
  - Markdown + YAML frontmatter
  - Common fields: `name`, `description`, `tools`, `model`, `hooks`, `skills`
- Agent Teams (experimental, separate from subagents):
  - Enable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `settings.json` `env` block
  - Lead session uses `TeamCreate` + `Task(team_name=...)` to spawn teammates
  - Teammates communicate peer-to-peer via `SendMessage`; shared task list via `TaskCreate`/`TaskList`
  - Config: `~/.claude/teams/{name}/config.json` (auto-created), `~/.claude/tasks/{name}/`
  - Cleanup: `TeamDelete` after all teammates shut down
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
- Invocation semantics (official):
  - Enable multi-agent via `/experimental` (toggle **Multi-agents**) or:
    ```toml
    [features]
    multi_agent = true
    ```
  - Configure roles via `[agents.<role>]` in Codex config.
  - Trigger role usage via prompt instruction; Codex orchestrates spawn/routing.
  - Use `/agent` to inspect/switch active agent threads.
  - Skills are invoked via `/skills` or `$skill-name`.
  - `@agent` mention syntax is not an official Codex spawn mechanism.
- Commands:
  - Custom prompts path: `~/.codex/prompts/*.md`
  - Invoked as `/prompts:<name>` (deprecated path)
- Skills:
  - `.agents/skills/*/SKILL.md`, `~/.agents/skills/*/SKILL.md`
  - Optional admin/system scopes (`/etc/codex/skills`, bundled system skills)
  - Official skill schema: skill directory with required `SKILL.md`; `SKILL.md` must include YAML frontmatter `name` and `description` + Markdown body
  - Optional skill resources: `scripts/`, `references/`, `assets/`, and `agents/openai.yaml` (UI metadata, invocation policy, dependencies)
- Hooks:
  - Limited documented callback: `notify` after agent turn completion
  - No full lifecycle event-hook map documented
- Tools:
  - TOML config controls including `approval_policy`, `sandbox_mode`, MCP servers

### Gemini CLI

- Subagents:
  - **Confirmed primary source**: `~/.gemini/agents/*.md` (user) or `.gemini/agents/*.md` (project)
  - Enable: `"experimental": { "enableAgents": true }` in `settings.json`
  - Agents exposed as tools to main agent; invoked automatically by description match
  - Gemini CLI can delegate tasks to remote subagents via Agent-to-Agent (A2A) protocol (`kind: remote`)
- Commands:
  - `.gemini/commands/**/*.toml`, `~/.gemini/commands/**/*.toml`
  - Directory nesting maps to command namespaces
- Skills:
  - `.gemini/skills/`, `~/.gemini/skills/`, extension skill directories
  - `.agents/skills/` and `~/.agents/skills/` are official aliases for workspace/user skill tiers
  - Within the same tier, `.agents/skills/` alias takes precedence over `.gemini/skills/`
  - Official skill schema: required `SKILL.md` with YAML frontmatter `name` and `description` + Markdown body instructions
  - Optional skill resources: `scripts/`, `references/`, `assets/`
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

## Sub-agent File Formats & Config Schemas

### Claude Code — Agent Teams

**Enable** (in `~/.claude/settings.json`):
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Team lead tools** (available when teams enabled): `TeamCreate`, `SendMessage`, `TaskCreate`, `TaskList`, `TaskUpdate`

**Agent `.md` frontmatter** (same as subagents, unchanged):
```yaml
---
name: developer
description: Code implementation, testing, and technical execution
tools: ["*"]
skills:
  - implement
hooks:
  SubagentStop:
    - type: command
      command: "..."
---
```

**Team lifecycle**:
- `TeamCreate(team_name, description)` → creates shared task list + team config
- `Task(subagent_type, team_name, prompt)` → spawns teammate in team context
- `SendMessage(type="message", recipient, content)` → peer-to-peer messaging
- `SendMessage(type="shutdown_request", recipient)` → graceful shutdown
- `TeamDelete()` → cleanup after all teammates shut down

**Best practices** (from official docs):
- 3–5 teammates; 5–6 tasks per teammate
- Each teammate owns distinct files (no shared-file edits)
- Provide task-specific context in spawn prompt (teammates don't inherit lead's history)
- Require plan approval for risky tasks: `Task(..., mode="plan")`
- Source: https://code.claude.com/docs/en/agent-teams.md

---

### Codex CLI — Multi-agent Roles

**Enable** (`~/.codex/config.toml`):
```toml
[features]
multi_agent = true
```
Or via `/experimental` → toggle **Multi-agents** → restart.

**Role definition** (`~/.codex/config.toml`):
```toml
[agents.jarvis-developer]
description = "Code implementation, testing, and technical execution"
config_file = "agents/jarvis-developer.toml"

[agents.jarvis-architect]
description = "System design, architecture documentation, and ADR creation"
config_file = "agents/jarvis-architect.toml"
```

**Per-role config file** (e.g. `~/.codex/agents/jarvis-developer.toml`):
```toml
model = "gpt-5.3-codex"
model_reasoning_effort = "high"
sandbox_mode = "untrusted"
developer_instructions = """
You are a Developer responsible for code implementation and testing.
[... full system prompt ...]
"""
```

**Role config schema**:

| Field | Type | Description |
|---|---|---|
| `model` | string | Model override for this role |
| `model_reasoning_effort` | string | `low`, `medium`, `high` |
| `sandbox_mode` | string | `untrusted`, `read-only` |
| `developer_instructions` | string | System prompt / role instructions |

**Built-in roles** (overridable by custom definition with same name):
- `default` — general-purpose fallback
- `worker` — execution-focused (implementation, fixes)
- `explorer` — read-heavy codebase exploration
- `monitor` — long-running commands / polling (supports `wait` tool, up to 1h)

**Schema constraints** (`[agents]` section):

| Field | Type | Description |
|---|---|---|
| `agents.max_threads` | number | Max concurrent agent threads |
| `agents.max_depth` | number | Max nesting depth (default: 1) |
| `agents.<name>.description` | string | Shown to Codex when selecting role |
| `agents.<name>.config_file` | string | Path to per-role TOML (relative to config.toml) |

**Invocation**: natural language prompt; Codex decides spawn/routing. Use `/agent` CLI to inspect threads.
Sub-agents inherit parent sandbox policy; run non-interactive. No peer-to-peer messaging.
- Source: https://developers.openai.com/codex/multi-agent.md

---

### Codex CLI — Skills (official)

**Skill locations**:
- Repo/user/admin/system scopes under `.agents/skills` and `/etc/codex/skills` (plus bundled system skills)

**Skill package schema**:
- A skill is a directory containing required `SKILL.md`
- `SKILL.md` must include YAML frontmatter fields:
  - `name` (required)
  - `description` (required)
- Body is Markdown instructions loaded on activation

**Optional files**:
- `scripts/` (executable helpers)
- `references/` (documentation)
- `assets/` (templates/resources)
- `agents/openai.yaml` (optional UI metadata + invocation policy + dependencies)

**Optional `agents/openai.yaml` capability examples**:
- `interface`: display metadata (name, description, icon, brand color, default prompt)
- `policy.allow_implicit_invocation`: disable implicit activation while keeping explicit `$skill`
- `dependencies.tools`: declare MCP/tool dependencies

**Invocation**:
- Explicit: `/skills` or `$skill-name`
- Implicit: matched from skill `description`
- Source: https://developers.openai.com/codex/skills

---

### Gemini CLI — Sub-agents

**Enable** (`~/.gemini/settings.json`):
```json
{
  "experimental": {
    "enableAgents": true
  }
}
```

**Agent definition file** (`~/.gemini/agents/<name>.md` or `.gemini/agents/<name>.md`):
```yaml
---
name: jarvis-developer
description: Code implementation, testing, and technical execution. Use for writing code, fixing bugs, and implementing features.
kind: local
tools:
  - read_file
  - write_file
  - replace_in_file
  - run_shell_command
  - grep_search
  - glob_files
max_turns: 20
---
You are a Developer responsible for code implementation and testing.

[... full system prompt / body ...]
```

**Frontmatter schema**:

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Slug: `[a-z0-9_-]` only. Used as tool name. |
| `description` | string | Yes | Shown to main agent for delegation decisions. Be specific about when to use. |
| `kind` | string | No | `local` (default) or `remote` (A2A protocol) |
| `tools` | array | No | Gemini tool names. Omit = all tools available. |
| `model` | string | No | e.g. `gemini-2.5-pro`. Default: `inherit` |
| `temperature` | number | No | 0.0–2.0 |
| `max_turns` | number | No | Max conversation turns (default: 15) |
| `timeout_mins` | number | No | Max execution time in minutes (default: 5) |

**Remote subagent schema nuance**:
- For remote subagents, `kind` is required and must be `remote`
- `agent_card_url` is required for remote subagents
- Remote definitions remain file-based under `.gemini/agents/*.md` / `~/.gemini/agents/*.md`
- Source: https://geminicli.com/docs/core/remote-agents/

**Gemini tool names** (reference mapping from Claude tool names):

| Claude | Gemini |
|---|---|
| `Read` | `read_file` |
| `Write` | `write_file` |
| `Edit` | `replace_in_file` |
| `Bash` | `run_shell_command` |
| `Glob` | `glob_files` |
| `Grep` | `grep_search` |
| `["*"]` / all | omit `tools` field |

**Built-in sub-agents** (enabled by default):
- `codebase_investigator` — deep codebase analysis, reverse engineering
- `cli_help` — expert knowledge about Gemini CLI itself
- `generalist_agent` — routes tasks to appropriate sub-agent
- `browser_agent` — browser automation (disabled by default)

**Invocation**: sub-agents are exposed as tools; main agent calls them automatically based on description.
No peer-to-peer messaging. Results report back to parent context only.
- Source: https://geminicli.com/docs/core/subagents/, https://geminicli.com/docs/reference/configuration/

---

### Gemini CLI — Skills (official)

**Skill locations**:
- `.gemini/skills/`, `~/.gemini/skills/`, extension-provided skill directories
- Official aliases: `.agents/skills/` (workspace) and `~/.agents/skills/` (user)

**Skill package schema**:
- A skill is a directory with required `SKILL.md`
- `SKILL.md` uses YAML frontmatter + Markdown instructions
- Frontmatter required fields:
  - `name` (unique identifier; should match directory name)
  - `description` (what the skill does and when to use it)

**Optional files**:
- `scripts/` (executable helpers)
- `references/` (static docs)
- `assets/` (templates/resources)

**Activation**:
- Skills can be explicitly requested or implicitly activated when the request matches skill semantics

**Discovery precedence (official)**:
- Tier precedence: Workspace > User > Extension
- Same-tier precedence: `.agents/skills/` alias overrides `.gemini/skills/`
- Operational impact: in dual Codex+Gemini installs, identically named skills in `.agents/skills/` can override Gemini-native `.gemini/skills/` skills
- Typical runtime warning:
  - `Skill conflict detected: "validate" from "~/.agents/skills/validate/SKILL.md" is overriding the same skill from "~/.gemini/skills/validate/SKILL.md"`
- Source: https://geminicli.com/docs/cli/skills/

- Source: https://geminicli.com/docs/cli/creating-skills/, https://geminicli.com/docs/cli/skills/

---

## Installer v0.2 Policy Mapping

1. Add `subagents` as a first-class capability dimension in runtime registry and reporting.
2. Keep Codex prompts as compatibility mode; prefer skills for new installs.
3. Treat Codex hooks as limited (`notify`) rather than equivalent to full lifecycle hook runtimes.
4. Treat Gemini as supporting both skills and hooks; old commands-only assumptions are stale.
5. Treat Qwen hooks as unsupported until official user-facing schema is published.
6. Keep `scripts` separate from `hooks` in capability and install logic.
7. Treat minimal-frontmatter transforms (`name`, `description`) as installer portability policy, not as a complete statement of runtime-native schema capabilities.
8. Account for Gemini alias precedence during multi-runtime installs: `.agents/skills/` can override `.gemini/skills/` within the same scope.

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
  - https://code.claude.com/docs/en/agent-teams.md *(agent teams, added 2026-02-24)*
- Codex CLI:
  - https://developers.openai.com/codex/multi-agent.md *(multi-agent roles schema, added 2026-02-24)*
  - https://developers.openai.com/codex/multi-agent
  - https://developers.openai.com/codex/config-basic
  - https://developers.openai.com/codex/config-reference
  - https://developers.openai.com/codex/custom-prompts
  - https://developers.openai.com/codex/skills
  - https://developers.openai.com/codex/cli/slash-commands
- Gemini CLI:
  - https://geminicli.com/docs/core/subagents/ *(sub-agent file format confirmed primary, added 2026-02-24)*
  - https://geminicli.com/docs/core/remote-agents/
  - https://geminicli.com/docs/reference/configuration/ *(settings.json schema, added 2026-02-24)*
  - https://geminicli.com/docs/hooks/
  - https://geminicli.com/docs/reference/commands/
  - https://geminicli.com/docs/cli/custom-commands/
  - https://geminicli.com/docs/cli/skills/
  - https://geminicli.com/docs/cli/creating-skills/
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
