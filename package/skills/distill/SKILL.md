---
name: distill
description: Lossless LLM-oriented document compression based on the BMAD distillator pattern. Use when asked to distill documents, dry up bloated docs, preserve dense high-signal context, remove managerial prose, create a distillate, compress requirements/architecture/tasks/notes for downstream agents, or produce a semantically split lossless context bundle.
---

# Distill

Produce lossless, LLM-optimized distillates from source documents. This is **compression**, not summarization: preserve every fact, decision, constraint, relationship, scope boundary, rationale, conflict, and open question while removing human-oriented overhead.

Baseline adapted from BMAD Method distillator at commit `ee47e30cf6bffb00eddfba4f4943df40071a3388`.

## Inputs

Accept:

- one or more source file paths, folder paths, or glob patterns;
- optional downstream consumer, e.g. `for architecture`, `for planner`, `for review`;
- optional token budget;
- optional output path;
- optional explicit request for independent round-trip validation.

If output path is omitted, write next to the primary source as `<base>-distillate.md`, or a `<base>-distillate/` folder for split output.

## Workflow

1. **Analyze sources.** Run the bundled helper; run it from this skill directory or resolve `scripts/analyze_sources.py` relative to this `SKILL.md` (do not assume a fixed install root):
   ```bash
   python3 scripts/analyze_sources.py <sources...>
   ```
   Use the routing and split prediction. If the script finds no files, stop and report the unresolved inputs.
2. **Read only the needed sources.** For small inputs, read sources directly. For large/fan-out inputs, process groups from the analysis output sequentially unless the user explicitly asked for subagents/parallelism.
3. **Extract losslessly.** Pull every discrete item:
   - facts, numbers, dates, versions;
   - requirements, constraints, acceptance criteria;
   - decisions and rationale;
   - rejected alternatives and reasons;
   - relationships, dependencies, ordering;
   - named entities;
   - open questions and unresolved conflicts;
   - scope in/out/deferred;
   - risks, success criteria, validation methods.
4. **Compress.** Apply `references/compression-rules.md`. Remove managerial bloat, repeated intros, rhetoric, hedging, filler, and decorative formatting.
5. **Deduplicate and preserve nuance.** Keep the most specific version of repeated information. If sources disagree, preserve the conflict explicitly instead of resolving it silently.
6. **Format.** Use `references/distillate-format.md`: frontmatter plus dense `##` sections and self-contained bullets. No prose paragraphs.
7. **Split semantically when needed.** If analysis predicts splitting or token budget requires it, use `references/splitting-strategy.md`; create `_index.md` plus self-contained section files.
8. **Verify.** Check that all source headings, named entities, IDs, decisions, constraints, and conflicts appear in the distillate. Run at most 2 targeted fix passes for gaps.
9. **Report JSON.** End with the file/folder path, source token estimate, distillate token estimate, compression ratio, and completeness status.

## Losslessness Rules

- Never drop details because they look verbose if they encode requirement nuance, rationale, history, or risk.
- Never collapse conflicting statements into one reconciled statement; mark the conflict.
- Never remove immutable IDs, statuses, dates, names, quantities, acceptance criteria, file paths, commands, or source references.
- Preserve reasoning, but compress it: `Decision: X; rationale: Y; rejected: Z because W`.
- Preserve user-stated invariants and explicit requirements at higher priority than implementation guesses.
- If downstream consumer is provided, drop only information clearly irrelevant to that consumer. When uncertain, keep it.

## Independent Round-Trip Validation

A meaningful round-trip check requires an independent context that has not read the originals. Only use subagents if the user explicitly asks for independent round-trip validation/subagents and the runtime permits it. Otherwise report: `round_trip_validation: skipped_requires_independent_context`.

When explicitly requested and available:

1. Give the validator only the distillate path, not the original files.
2. Ask it to reconstruct likely source content and flag possible gaps.
3. Compare reconstruction with originals for missing facts, altered relationships, or hallucinated filler.
4. Save `<distillate>-validation-report.md` with PASS/PASS_WITH_WARNINGS/FAIL.
5. Delete temporary reconstructions unless the user asks to keep them.

## Output Shapes

Single distillate frontmatter:

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

Split folder:

```text
<base>-distillate/
├── _index.md
├── 01-<topic>.md
└── 02-<topic>.md
```

Final response:

```json
{
  "status": "complete",
  "distillate": "path-or-folder",
  "section_distillates": null,
  "source_total_tokens": 0,
  "distillate_total_tokens": 0,
  "compression_ratio": "0:1",
  "source_documents": [],
  "completeness_check": "pass"
}
```

## Anti-Patterns

- Summarizing instead of preserving source information.
- Keeping managerial bloat because it sounds important.
- Removing rationale, rejected alternatives, or conflicts.
- Arbitrary size-based splits that break semantic coherence.
- Running round-trip validation in the same context that read originals and calling it independent.
