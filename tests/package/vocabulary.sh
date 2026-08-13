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

SCAN=("package" "AGENTS.md" "docs/INDEX.md")

# A line that names a retired flow in order to forbid it is documentation, not a
# regression. Keep this allowlist keyed on intent, never on file or line number.
ALLOW_RE='retired, not renamed'

FAILURES=0
PASS=0

check_absent() {
    local name="$1"
    local desc="$2"
    local pattern="$3"
    local hits
    hits=$(grep -rnE "$pattern" "${SCAN[@]}" 2>/dev/null | grep -vE "$ALLOW_RE" || true)
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
