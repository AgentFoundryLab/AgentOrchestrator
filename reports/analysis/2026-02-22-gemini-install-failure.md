# Analysis: Gemini CLI Installation Failure

**Date**: 2026-02-22
**Scope**: Troubleshooting Gemini CLI command installation and TOML validation errors.
**Conclusion**: Installation fails due to a schema mismatch in generated TOML files and improper escaping of backslashes in skill bodies.

## Context
Multiple errors were reported by Gemini CLI's `FileCommandLoader` stating that command files in `/home/node/.gemini/commands/` are invalid or fail to parse.

## Investigation

### Approach
1.  Analyzed `install.sh` logic for Gemini TOML generation (`skill_to_gemini_toml`).
2.  Verified generated TOML files against Gemini CLI's expected schema (via `cli_help`).
3.  Validated TOML syntax using `python3 tomllib`.
4.  Examined source `SKILL.md` templates for problematic characters.

### Findings

#### Finding 1: Schema Mismatch (Critical)
The `install.sh` script wraps command fields in a `[command]` table:
```toml
[command]
name = "..."
description = "..."
prompt = """..."""
```
However, Gemini CLI expects these fields to be at the **top level** of the TOML file. Additionally, the `name` field is unnecessary as Gemini derives the command name from the filename. This causes all generated commands to be rejected as "invalid".

#### Finding 2: TOML Syntax Error in `research.toml`
The `research.toml` file fails to parse with:
`tomllib.TOMLDecodeError: Unescaped '\\' in a string`
This occurs because the `prompt` field uses triple-quoted basic strings (`"""..."""`), which treat `\` as an escape character. The skill body contains escaped backticks (`\`\`\``), resulting in `\` followed by `` ` ``, which is an invalid escape sequence in TOML.

#### Finding 3: Escaped Backticks in Templates
The source file `package/skills/research/SKILL.md` contains escaped backticks:
```markdown
### Code Examples
\`\`\`language
// Example from research
\`\`\`
```
These literal backslashes are carried over into the TOML `prompt` and trigger the syntax error described in Finding 2.

## Root Cause
1.  **Inaccurate `install.sh` implementation**: The `skill_to_gemini_toml` function follows an incorrect schema and fails to escape backslashes for TOML basic strings.
2.  **Template Artifacts**: `SKILL.md` files contain backslash-escaped backticks that are incompatible with raw inclusion in TOML basic strings.

## Impact
None of the orchestrated skills are available as commands in Gemini CLI, rendering the installation non-functional for this runtime.

## Recommendations
1.  **Update `install.sh`**:
    *   Remove `[command]` table and `name` field from `skill_to_gemini_toml`.
    *   Escape all backslashes in the body (`sed 's/\\\\/\\\\\\\\/g'`) before inserting into the `prompt` string.
    *   Consider using TOML literal strings (`'''`) if Gemini supports them, to avoid escape issues entirely.
2.  **Clean up Templates**: Remove unnecessary backslash escapes from `SKILL.md` templates or ensure the installer strips them.

## Related
- `install.sh`: `skill_to_gemini_toml` function
- `docs/architecture/adr/014-multi-agent-installer.md`
- `package/skills/*/SKILL.md`
