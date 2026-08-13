# Semantic Splitting Strategy

Split by meaning, not size.

## When to Split

- Source analysis recommends fan-out.
- Estimated distillate exceeds ~5,000 tokens.
- User provides a token budget that a single distillate cannot satisfy.

## Boundaries

Prefer coherent sections:

- product problem / solution;
- requirements / acceptance criteria;
- architecture / technical decisions;
- workflow / operations;
- risks / open questions;
- current state / target state;
- stakeholder-specific context.

## Split Output

`_index.md` contains:

- 3-5 orientation bullets;
- source list and downstream consumer;
- section manifest;
- cross-cutting decisions, constraints, conflicts, and scope boundaries.

Each section file:

- starts with: `This section covers <topic>. Part N of M.`;
- is self-contained;
- includes local facts/decisions/risks;
- cross-references related sections only when needed.
