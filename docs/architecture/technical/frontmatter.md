# Frontmatter Specification

This document defines the supported YAML frontmatter fields for agent and skill definitions across all supported runtimes.

## Agent Frontmatter

Agent definitions use YAML frontmatter in `.md` files. The installer transforms these for each runtime's native format.

### Source Format (Claude-style)

```yaml
---
name: agent-name
description: One-line description of what this agent does
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebSearch
  - WebFetch
  - Task
  - AskUserQuestion
disallowedTools:
  - Bash
skills:
  - spec
  - hitl
hooks:
  SubagentStop:
    - type: command
      command: "..."
---
```

### Field Reference

| Field | Type | Required | Claude | Codex | Gemini | OpenCode | Qwen |
|-------|------|----------|--------|-------|--------|----------|------|
| `name` | string | Yes | ✓ | ✓ | ✓ | ✗ (filename) | ✓ |
| `description` | string | Yes | ✓ | ✓ | ✓ | ✓ | ✓ |
| `tools` | array | No | ✓ | ✓ | ✓ | transform → permission | ✓ |
| `disallowedTools` | array | No | ✓ | ✗ | ✗ | ✗ | ✗ |
| `skills` | array | No | ✓ | ✗ | ✗ | ✗ | ✗ |
| `hooks` | object | No | ✓ | ✗ | ✗ | ✗ | ✗ |
| `model` | string | No | ✓ | ✓ | ✓ | ✓ | ✓ |
| `temperature` | number | No | ✓ | ✓ | ✓ | ✓ | ✓ |
| `mode` | string | No | ✗ | ✗ | ✗ | ✓ | ✗ |
| `kind` | string | No | ✗ | ✗ | ✓ | ✗ | ✗ |

### Runtime-Specific Transformations

#### Claude Code
No transformation. Native format.

#### Codex
- Strip: `disallowedTools`, `skills`, `hooks`
- Lowercase tool names: `Read` → `read`

#### Gemini
- Strip: `disallowedTools`, `skills`, `hooks`
- Map tool names: `Read` → `read_file`, `Bash` → `run_shell_command`
- Add `kind: local` if absent

#### OpenCode
- Strip: `name`, `disallowedTools`, `skills`, `hooks`
- Transform `tools` array to `permission` object:

```yaml
# Before (tools array)
tools: [Read, Write, Edit]

# After (permission object)
permission:
  read: allow
  write: allow
  edit: allow
```

- Add `mode: subagent` (default) or `mode: primary` for main agents

#### Qwen
- Strip: `disallowedTools`, `skills`, `hooks`
- Map tool names similar to Gemini

## Tool Name Mapping

### Claude → Target Runtime

| Claude Tool | Codex | Gemini | OpenCode | Qwen |
|-------------|-------|--------|----------|------|
| `Read` | `read` | `read_file` | `read` | `read_file` |
| `Write` | `write` | `write_file` | `write` | `write_file` |
| `Edit` | `edit` | `replace` | `edit` | `replace` |
| `Glob` | `glob` | `glob` | `glob` | `glob` |
| `Grep` | `grep` | `grep_search` | `grep` | `grep_search` |
| `Bash` | `bash` | `run_shell_command` | `bash` | `run_shell_command` |
| `ListDirectory` | `list` | `list_directory` | `list` | `list_directory` |
| `WebSearch` | `web_search` | `google_web_search` | `websearch` | `web_search` |
| `WebFetch` | `web_fetch` | `web_fetch` | `webfetch` | `web_fetch` |
| `Task` | `task` | `task` | `task` | `task` |
| `AskUserQuestion` | `ask_user` | `ask_user` | `question` | `ask_user` |
| `*` | `*` | `*` | `*` | `*` |

### Wildcard Tools

The wildcard `*` grants access to all available tools.

- **Claude**: `tools: ["*"]`
- **Gemini**: `tools: ["*"]` (inherits all from parent session)
- **OpenCode**: `permission: {"*": allow}`

## Skill Frontmatter

Skills use similar frontmatter with additional skill-specific fields.

### Source Format

```yaml
---
name: skill-name
description: One-line description
argument-hint: <args description>
user-invocable: true
allowed-tools:
  - Read
  - Glob
context: inject
agent: agent-name
---
```

### Field Reference

| Field | Type | Required | Claude | Codex | Gemini | OpenCode | Qwen |
|-------|------|----------|--------|-------|--------|----------|------|
| `name` | string | Yes | ✓ | ✓ | ✓ | ✓ | ✓ |
| `description` | string | Yes | ✓ | ✓ | ✓ | ✓ | ✓ |
| `argument-hint` | string | No | ✓ | ✗ | ✗ | ✗ | ✗ |
| `user-invocable` | bool | No | ✓ | ✗ | ✗ | ✗ | ✗ |
| `allowed-tools` | array | No | ✓ | ✓ | ✓ | ✓ | ✓ |
| `context` | string | No | ✓ | ✗ | ✗ | ✗ | ✗ |
| `agent` | string | No | ✓ | ✗ | ✗ | ✗ | ✗ |

## Extra Agents

Some runtimes have additional agents installed from `package/agents-also-run/<runtime>/`.

### Registry

| Runtime | Extra Agents |
|---------|--------------|
| claude | (none) |
| codex | (none) |
| gemini | (none) |
| opencode | `orchestrator` |
| qwen | (none) |

### orchestrator.md (OpenCode-only)

A primary agent for project orchestration:

```yaml
---
description: Guide a project from idea to implementation...
mode: primary
permission:
  "*": allow
---
```

References the `orchestrate` skill for workflow details.

## Implementation Notes

1. **Determinism**: Same input always produces same output regardless of install order
2. **Unknown keys**: Installer warns but continues for unknown frontmatter keys
3. **Transform location**: `install.sh` functions `normalize_agent_markdown_in_place` and `normalize_skill_markdown_in_place`
4. **Registry**: `package/install/runtimes.sh` defines per-runtime transform specs