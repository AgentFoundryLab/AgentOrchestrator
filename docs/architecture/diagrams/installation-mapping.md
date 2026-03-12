# Installation Target Mapping

```
REPOSITORY                              INSTALLATION TARGETS

orchestrator/
|
+-- package/                ---------------------> <runtime-global-root>/
|   +-- agents/                                   +-- agents/
|   |   +-- *.md            [warn if different]   |   +-- *.md
|   +-- skills/                                   +-- skills/
|   |   +-- */SKILL.md      [warn if different]   |   +-- */SKILL.md
|   +-- hooks/                                    +-- hooks/              (runtime support varies)
|   |   +-- scripts/*.sh    [backup + overwrite]      +-- scripts/*.sh
|   +-- settings.json       [patch/merge]         +-- settings.json       (runtime-specific where supported)
|   +-- mcp.json            [patch/merge]         +-- runtime MCP config  (Claude-specific today)
|   +-- policy/                                   +-- policy/
|   +-- workflows/                                +-- workflows/
|   +-- templates/                                +-- templates/
|
+-- package/                ---------------------> <target-project>/
    +-- agents/                                   +-- <runtime-root>/agents/
    +-- skills/                                   +-- <runtime-root>/skills/
    +-- policy/                                   +-- <runtime-root>/policy/
    +-- workflows/                                +-- <runtime-root>/workflows/
    +-- templates/                                +-- <runtime-root>/templates/
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
