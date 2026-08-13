# Compression Rules

Apply as the final pass over every distillate.

## Strip

Remove entirely:

- prose transitions: "as mentioned earlier", "in addition", "worth noting";
- rhetoric/persuasion: "game-changer", "exciting", "robust", "seamless" when not a requirement;
- hedging: "we believe", "likely", "perhaps", "it seems" unless uncertainty itself matters;
- self-reference: "this document describes", "as outlined above";
- common-knowledge explanations;
- repeated introductions of the same concept;
- section transition paragraphs;
- decorative bold/italic and horizontal rules;
- filler: "in order to", "it should be noted", "the fact that".

## Preserve Always

Keep:

- numbers, dates, versions, percentages, names;
- explicit requirements, constraints, acceptance criteria;
- decisions and rationale;
- rejected alternatives and reasons;
- dependencies, ordering, ownership, lifecycle, role boundaries;
- open questions and unresolved conflicts;
- scope boundaries: in, out, deferred;
- success criteria and validation methods;
- risks with severity signals;
- source IDs and references.

## Transform

- Long paragraph → one dense bullet preserving all facts.
- Decision prose → `Decision: X; rationale: Y`.
- Rejection prose → `Rejected: X; reason: Y`.
- Conditional prose → `If X → Y`.
- Multi-sentence explanation → semicolon-separated compressed clause.
- Repeated labels → one thematic heading.
- Related short items → parenthetical list.

## Deduplicate

- Same fact in multiple places → keep most specific/contextual version.
- Same concept at different detail levels → keep detailed version.
- Overlapping lists → merge without duplicates.
- Conflicting sources → preserve as conflict: `Source A says X; Source B says Y — unresolved`.
- Executive summary repeated in body → keep body detail, drop summary repeat.
