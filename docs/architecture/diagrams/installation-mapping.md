# Installation Target Mapping

```
REPOSITORY                              INSTALLATION TARGETS

orchestrator/
|
+-- package/                ---------------------> ~/.claude/
|   +-- agents/                                   +-- agents/jarvis/
|   |   +-- *.md            [warn if different]   |   +-- *.md
|   +-- skills/                                   +-- skills/jarvis/
|   |   +-- */SKILL.md      [warn if different]   |   +-- */SKILL.md
|   +-- hooks/                                    +-- hooks/
|   |   +-- scripts/*.sh    [backup + overwrite]      +-- scripts/*.sh
|   +-- settings.json       [patch/merge]         +-- settings.json
|   +-- mcp.json            [patch/merge]         +-- ~/.claude.json:mcpServers
|   +-- policy/                                   +-- policy/
|   +-- workflows/                                +-- workflows/
|   +-- templates/                                +-- templates/
|
+-- package/                ---------------------> <target-project>/
    +-- agents/                                   +-- .claude/agents/jarvis/
    +-- skills/                                   +-- .claude/skills/jarvis/
    +-- policy/                                   +-- .claude/policy/
    +-- workflows/                                +-- .claude/workflows/
    +-- templates/                                +-- .claude/templates/
    +-- templates/{knowledge,standards,guidelines}.md
        [create/warn]                             +-- docs/{knowledge,policy}/...
    +-- (scaffold dirs)                           +-- docs/*, reports/*, .serena/
```

## Installation Behavior by File Type

| File Type | Behavior |
|-----------|----------|
| `*.json` (settings, mcp) | **PATCH**: Deep merge, preserve user keys, backup first |
| `*.md` (agents, skills) | **WARN**: If exists and different, warn (or overwrite with `--overwrite`). |
| `*.sh` (hooks) | **BACKUP + OVERWRITE**: Scripts must match Orchestrator version. Backup to ~/.claude/backups/ |
| New files | **CREATE**: No conflict, just copy |
