# Distillate Format

Distillates are dense context artifacts for LLM consumption.

## Rules

- YAML frontmatter first.
- `##` headings only; no deeper heading levels unless source IDs require it.
- Bullets only; no prose paragraphs.
- Every bullet must be self-contained.
- Prefer compact relationship forms: `X owns Y`, `X blocks Y`, `X replaces Y`, `X because Y`.
- No decorative emphasis.
- Preserve exact IDs, commands, paths, model names, schema names, route names, and dates.

## Single File Frontmatter

```yaml
---
type: bmad-distillate
sources:
  - "relative/source.md"
downstream_consumer: "general"
created: "YYYY-MM-DD"
token_estimate: 1200
parts: 1
---
```

## Bullet Examples

- `Decision: Use single gateway for AI calls; rationale: centralizes provider policy, telemetry, and retries.`
- `Rejected: direct provider calls in route handlers; reason: duplicates auth/error/observability logic.`
- `Conflict: WO-010 says preview gate required before status update; STATUS says local-only validation complete — unresolved.`
