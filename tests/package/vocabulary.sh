#!/usr/bin/env bash
# tests/package/vocabulary.sh
# Guards the distributed package against pre-migration vocabulary re-entering an
# instruction surface.
#
# Two classes are checked, because they fail differently:
#   - retired *identifiers* (PRD, BACKLOG, ...) — a grep for the token finds these;
#   - retired *concepts* (evidence living in a detail section of an index rather
#     than in its own record document) — these carry no retired token, so a
#     token sweep is blind to them. Every such regression found so far was of the
#     second class, which is why it is gated separately.
#
# Usage: bash tests/package/vocabulary.sh
# Requirements: bash 4.0+, no external dependencies.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${PROJECT_ROOT}"

# Every surface a reader is handed: the distributed package, the runtime entry
# points, and the two that ship user-facing prose about the record set — the
# README and the installer's own --help output. README.md and install.sh were
# added after both were found still advertising retired artifacts; a gate that
# skips a surface is why drift survives there.
SCAN=("package" "AGENTS.md" "docs/INDEX.md" "README.md" "install.sh" "tests" ".github")

# docs/** is deliberately absent. ID-MAP.md, docs/archive/, and docs/development/tasks/ exist to
# record the pre-migration ids and must keep them; scanning them would fail the id-grammar check
# on the one surface whose job is to hold those ids.

# A line that names a retired flow in order to forbid it is documentation, not a
# regression. Keep this allowlist keyed on intent, never on file or line number.
ALLOW_RE='retired, not renamed'

FAILURES=0
PASS=0

check_absent() {
    local name="$1"
    local desc="$2"
    local pattern="$3"
    local allow="${4:-$ALLOW_RE}"
    local hits
    # This file states every forbidden pattern in order to forbid it, so scanning tests/
    # makes it match itself. The definition of a rule is not a violation of it.
    hits=$(grep -rnE --exclude=vocabulary.sh "$pattern" "${SCAN[@]}" 2>/dev/null | grep -vE "$allow" || true)
    if [ -z "$hits" ]; then
        echo "PASS: $name"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $name — $desc"
        printf '%s\n' "$hits" | sed 's/^/    /'
        FAILURES=$((FAILURES + 1))
    fi
}

echo ""
echo "=== Package Vocabulary Conformance ==="
echo ""

check_absent "retired-artifact-ids" \
    "names an artifact the record schema retired" \
    '\b(PRD|BACKLOG|ARCHITECTURE\.md|task-detail|TASKS\.md)\b'

check_absent "retired-feedback-model" \
    "places record evidence in an index detail section instead of its own ISS/REG document" \
    'detail subsection|detail section|Active Issue Details'

# $reflexion, $reflect, and $optimize were absorbed into $meta-learn (REQ-007 is
# Decommissioned, superseded by REQ-008). A surface still naming one as a live skill
# sends an agent to a skill that will not resolve. Lines that name it while framing it
# as history -- absorbed, collapsed, superseded, retired, no longer exists -- are
# documenting the change; the allowlist is keyed on that framing, never on a file path.
check_absent "retired-learning-skills" \
    "invokes a skill that \$meta-learn absorbed" \
    '[/$]`?(reflexion|reflect|optimize)\b' \
    'absorbed|collapsed|superseded|retired|no longer exist'

# WO-181's integration test — "no live instruction surface retains a pre-migration id form" — was
# implemented by nothing, which is how ~36 T-/I-/G- references survived the migration in install.sh,
# runtimes.sh, smoke.sh, and install-ci.yml. Ids are the traceability spine: a comment citing T-095
# sends a reader to a record no index resolves. The allowlist keys on framing, so ID-MAP-style prose
# naming an old form as retired still passes.
check_absent "pre-migration-id-grammar" \
    "cites a pre-migration T-/I-/G- id where the record schema uses WO/ISS/REG/TD" \
    '\b[TIG]-[0-9]{3}\b' \
    'pre-migration|retired|superseded|resolves the|ID-MAP'

check_absent "retired-task-vocabulary" \
    "refers to tasks where the record schema uses Work Orders and record ids" \
    '\btask (number|numbers|ids)\b'

echo ""
echo "==================================="
echo "Results: $((PASS + FAILURES)) checks, ${PASS} passed, ${FAILURES} failed"
echo "==================================="

if [ "$FAILURES" -gt 0 ]; then
    echo "VOCABULARY DRIFT DETECTED"
    exit 1
fi
echo "ALL CHECKS PASSED"
