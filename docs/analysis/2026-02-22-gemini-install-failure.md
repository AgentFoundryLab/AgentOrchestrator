# Analysis: Gemini CLI Installation Failure

**Date**: 2026-02-24
**Scope**: Troubleshooting Gemini CLI command installation and TOML validation errors following T-092 and T-097 updates.
**Conclusion**: Installation still fails due to persistent TOML schema validation errors, parsing failures caused by overly-aggressive frontmatter stripping, and new cross-runtime skill conflicts exposed by the transition to a skills-first baseline.

## Context
Multiple errors are still reported by Gemini CLI's `FileCommandLoader` stating that command files in `/home/node/.gemini/commands/` are invalid or fail to parse. Additionally, the transition to native skill support (T-097) has exposed namespace conflicts with the Codex runtime path.

## Investigation

### Approach
1. Analyzed `FileCommandLoader` error output post-T-092 schema fixes.
2. Examined the `install.sh` `strip_frontmatter` and `skill_to_gemini_toml` functions.
3. Reviewed the new `Skill conflict detected` warnings that appeared after T-097.

### Findings

#### Finding 1: Persistent Schema Validation Errors
Despite removing the `[command]` table in T-092, `FileCommandLoader` continues to reject `.toml` files (e.g., `spec.toml`, `validate.toml`) with empty "Validation errors:". This suggests the generated TOML is still missing a strictly required field, or the `prompt` field is being rejected for other formatting reasons not covered by the `cli_help` documentation.

#### Finding 2: TOML Parse Failures & Truncation
Files like `research.toml` and `orchestrate.toml` explicitly fail to parse. The root cause is the `strip_frontmatter` function in `install.sh`:
```bash
awk '/^---$/{found++; if(found==2){found=0; skip=0; next} else {skip=1; next}} !skip' "$src"
```
This `awk` script inadvertently triggers on `---` horizontal rules within the Markdown body (such as those in `research/SKILL.md`), stripping out large chunks of the command body and truncating the files. The aggressive escaping of double quotes (`"`) in basic TOML strings (`"""`) may also be contributing to the parse failures.

#### Finding 3: Cross-Runtime Skill Conflicts (T-097 Impact)
Following T-097, Gemini CLI now natively loads skills. However, the runtime emits warnings like:
```text
⚠  Skill conflict detected: "validate" from "/home/node/.agents/skills/validate/SKILL.md" is overriding the same skill from
   "/home/node/.gemini/skills/validate/SKILL.md".
```
This indicates Gemini CLI is scanning *both* its native path (`.gemini/skills/`) and the Codex path (`.agents/skills/`). Because the multi-agent installer populates both directories during a global install, Gemini CLI attempts to load duplicates of every skill, causing widespread conflicts.

## Root Cause
1. **Aggressive Frontmatter Stripping**: `strip_frontmatter` incorrectly removes Markdown horizontal rules (`---`), destroying the command body.
2. **Incomplete Schema Fixes**: The T-092 fix did not fully satisfy `FileCommandLoader`'s undocumented schema requirements.
3. **Un-isolated Runtime Scanning**: Gemini CLI aggressively scans alternative runtime paths (`.agents/skills/`), which conflicts with the installer's per-runtime artifact distribution.

## Impact
- **Commands Mode**: Remains completely non-functional for Gemini due to validation and parsing errors.
- **Skills Mode**: Functional, but heavily degraded by spammy conflict warnings due to un-isolated path loading.

## Recommendations
1. **Fix `strip_frontmatter`**: Update the logic to only strip the *first* YAML block (e.g., stopping after the second `---` is encountered) and ignore subsequent horizontal rules.
2. **Refine TOML Generation**: Switch `skill_to_gemini_toml` to use TOML literal multiline strings (`'''`) to avoid escaping bugs entirely, and investigate if re-adding the `name` field resolves the validation errors.
3. **Address Path Conflicts**: Document the cross-read behavior (similar to OpenCode). The installer may need to be updated to skip duplicating artifacts to `.gemini/skills/` if it detects them in `.agents/skills/`, or Gemini CLI needs to be configured to isolate its scan paths.