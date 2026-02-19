# Project Policy Files

This directory contains project-specific policy outputs that supplement (not replace) global policy in `~/.claude/policy/`.

## Effective Hierarchy

```
~/.claude/policy/         # Global (framework-level)
├── PRINCIPLES.md         # Engineering principles
└── RULES.md              # Orchestrator behavior rules

docs/policy/              # Project-local (this directory)
├── STANDARDS.md          # MUST-level technical constraints/conventions
└── GUIDELINES.md         # SHOULD-level process guidance
```

## When to Update These Files

- Update `STANDARDS.md` for enforceable conventions and constraints.
- Update `GUIDELINES.md` for recommended workflows and practices.
- Keep both aligned with architecture and roadmap changes.
