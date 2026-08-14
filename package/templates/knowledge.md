# Project Knowledge Base

This directory contains accumulated project knowledge that persists across sessions.

---

## Purpose

Store domain-specific information that helps agents understand your project:
- Domain concepts and terminology
- API patterns and conventions
- Architecture decisions and rationale
- Troubleshooting runbooks
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
└── runbooks/             # Procedures, SOPs, workflows
    └── debugging.md    # Common issues
```

---

## Best Practices

1. **Keep It Current**: Update when decisions change
2. **Be Specific**: Include examples, not just rules
3. **Link to Code**: Reference actual implementations
4. **Avoid Duplication**: Don't duplicate architecture docs

---

## Integration with Serena

Serena MCP provides persistent memory and symbolic code operations across sessions. The `Setup` hook creates `.serena/memories/` for it.

No skill writes Serena memories. Durable findings are files: knowledge under `docs/knowledge/`, analysis under `docs/analysis/`, instruction-fix memos under `reports/meta-optimization/`. Treat memory as a supplement you opt into, and keep the file record authoritative.

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
