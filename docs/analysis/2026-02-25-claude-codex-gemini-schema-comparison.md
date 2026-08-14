# Comparative Report: Claude vs Codex vs Gemini

Date: 2026-02-25 (revised)
Scope: agents / skills / commands schema and frontmatter
Sources: official runtime docs + local ADR/report synthesis

| Artifact | Claude Code | Codex CLI | Gemini CLI |
|---|---|---|---|
| Agents schema / frontmatter | File-based agents: `.claude/agents/*.md` with YAML frontmatter; common keys include `name`, `description`, `tools`, `model`, `hooks`, `skills`. | No Markdown agent frontmatter model. Multi-agent is role-driven TOML: `[agents.<name>]` + `config_file` in `config.toml`, with per-role TOML (`model`, `model_reasoning_effort`, `sandbox_mode`, `developer_instructions`). | File-based agents: `.gemini/agents/<name>.md` with YAML frontmatter. Required: `name`, `description`. Optional: `kind`, `tools`, `model`, `temperature`, `max_turns`, `timeout_mins`. |
| Skills schema / frontmatter | Native `SKILL.md` + YAML frontmatter in `.claude/skills/<name>/SKILL.md`; commonly uses `name`, `description`, `argument-hint`, `context`, `agent`, plus policy keys like `user-invocable` / `disable-model-invocation`. | Official Codex skill schema is directory-based with required `SKILL.md` containing YAML frontmatter `name` + `description` and Markdown body. Optional package resources: `scripts/`, `references/`, `assets/`, and optional `agents/openai.yaml` metadata/policy/dependencies. | Official Gemini skill schema is directory-based with required `SKILL.md` containing YAML frontmatter `name` + `description` and Markdown body. Optional package resources: `scripts/`, `references/`, `assets/`. |
| Commands schema / frontmatter | Preferred model is skills-as-commands (`/name`) rather than separate command files; legacy `.claude/commands/*.md` still exists. | Command-like custom prompts are legacy/deprecated: `~/.codex/prompts/*.md`, invoked as `/prompts:<name>`. Structured frontmatter schema is not the primary model here. | Commands are TOML files in `.gemini/commands/**/*.toml`; directory namespace maps to `/<ns>:<cmd>`. `prompt` is required; `description` optional. |
| Namespace / invocation shape | Flat by default for project/user skills+commands (`/name`); plugin-owned namespace uses `plugin:skill`. | Flat skill naming; invoke via `$skill` or `/skills`; implicit invocation by description is supported; legacy prompts via `/prompts:<name>`. | Commands have native namespacing by directory: `commands/<ns>/<cmd>.toml` -> `/<ns>:<cmd>`. |
| Agent-specific settings | Hooks can be configured in settings and frontmatter hook blocks. | Multi-agent roles configured in `config.toml`; no Markdown agent frontmatter contract. | `kind` for custom agents: `local` (default) or `remote`. For remote agents, `kind: remote` and `agent_card_url` are required. Gemini can delegate tasks to remote subagents via A2A protocol. |
| Cross-runtime transform notes (installer policy, not runtime schema) | Source schema keeps Claude keys. | Installer portability layer may strip Claude-only keys in transformed outputs; this does not redefine Codex native skill support. | Installer portability layer may strip Claude-only keys and convert command placeholders (`$ARGUMENTS` -> `{{args}}`) for Gemini command mode. |

## Notes

- ADR-014 (2026-02-20) marks Gemini file-based agents as inferred from secondary docs.
- The capability report update (2026-02-24) marks Gemini file-based agents as confirmed from primary docs.
- Treat the report as newer on that point.
- Minimal-frontmatter transform rules in installer ADRs are implementation choices for portability; they are not the full official Codex/Gemini skill schemas.
- Gemini skills conflict warning to expect when duplicate names exist across alias/native paths:
  - `Skill conflict detected: "validate" from "~/.agents/skills/validate/SKILL.md" is overriding the same skill from "~/.gemini/skills/validate/SKILL.md"`

## Sources used

- Official docs:
  - https://developers.openai.com/codex/skills
  - https://developers.openai.com/codex/multi-agent.md
  - https://geminicli.com/docs/core/subagents/
  - https://geminicli.com/docs/core/remote-agents/
  - https://geminicli.com/docs/reference/configuration/
  - https://geminicli.com/docs/cli/skills/
  - https://geminicli.com/docs/cli/creating-skills/
- Local project refs:
  - `reports/research/2026-02-22-agent-capability-report.md`
  - `docs/architecture/adr/014-multi-agent-installer.md`
  - `docs/architecture/adr/004-skill-agent-invocation-paths.md`
  - `docs/architecture/adr/013-extended-skills.md`
