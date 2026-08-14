# Project Knowledge Base

This directory contains accumulated project knowledge that persists across sessions.

---

## Purpose

Store domain-specific information that helps agents understand your project:
- Domain concepts and terminology
- API patterns and conventions
- Technical and operational decisions (non-ADR)
- Operational runbooks
- Team conventions

---

## How It's Used

Files in this directory are available to agents via Read/Grep tools. Agents may reference this knowledge when:
- Making design decisions
- Understanding existing patterns
- Troubleshooting issues
- Writing documentation

---

## Suggested Structure

```
knowledge/
├── README.md           # This file
├── domain/             # Domain concepts
│   ├── glossary.md     # Term definitions
│   └── concepts.md     # Core concepts
├── patterns/           # Code patterns
│   ├── api.md          # API conventions
│   └── testing.md      # Testing patterns
├── decisions/          # Key decisions
│   └── tech-stack.md   # Technology choices
└── runbooks/           # Procedures, SOPs, workflows
    └── debugging.md    # Common issues
```

---

## Decision Types

- **ADRs** (`docs/architecture/ADR/`): significant architecture decisions with alternatives and consequences, tier-scoped as `ADR-<TIER>-NNN`.
- **Technical decision records (TDRs)** (`docs/knowledge/decisions/`): lightweight technical/operational decisions, protocols, and guidance that do not rise to ADR scope.

Do not duplicate ADR content in `docs/knowledge/decisions/`; link or summarize when needed.

---

## Best Practices

1. **Keep It Current**: Update when decisions change
2. **Be Specific**: Include examples, not just rules
3. **Link to Code**: Reference actual implementations
4. **Avoid Duplication**: Don't duplicate architecture docs

---

## Integration with Serena

Serena MCP provides persistent memory and symbolic code operations across sessions. The `Setup` hook creates `.serena/memories/` for it.

No skill writes Serena memories. Durable findings are files: knowledge here, analysis and instruction-fix memos under `reports/`. The tiered memory model in [`ADR-FND-002`](../architecture/ADR/ADR-FND-002.md) is the design, not observed behavior.

See [.serena/README.md](../../.serena/README.md) for setup and tooling.

---

## Adding Knowledge

1. Create markdown file in appropriate subdirectory
2. Use clear headings and structure
3. Include practical examples
4. Reference related documentation

**Template**:
```markdown
# [Topic]

## Overview
[Brief description]

## Details
[Detailed information]

## Examples
[Practical examples]

## Related
- [Link to related docs]
```
