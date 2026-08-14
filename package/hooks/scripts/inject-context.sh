#!/bin/bash
# inject-context.sh - SessionStart/SubagentStart hook
# Non-blocking execution

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

case "$HOOK_EVENT" in
    SessionStart)
        write_session_start_jsonl
        ;;
    SubagentStart)
        [ -z "$AGENT_ID" ] && { echo "Missing agent_id" >&2; exit 1; }
        write_agent_start_jsonl
        ;;
esac

# knowledge_index — a bounded listing of docs/knowledge/ (AC-005.2).
# A pointer alone is not discovery: an agent that does not know the directory exists will not
# look in it. Names only, capped, so a large knowledge base cannot flood session context.
knowledge_index() {
    local kb="${CWD}/docs/knowledge"
    [ -d "$kb" ] || return 0
    local entries
    entries=$(find "$kb" -mindepth 1 -maxdepth 1 \( -type d -o -name '*.md' \) \
        -not -name '.*' -printf '%f\n' 2>/dev/null | sort | head -12 | tr '\n' ',' | sed 's/,$//; s/,/, /g')
    [ -n "$entries" ] || return 0
    printf 'Knowledge: docs/knowledge/ — %s\n' "$entries"
}

# Output context for Claude (SessionStart stdout goes to context).
# PROJECT_NAME and the knowledge index are SessionStart-only: a sub-agent inherits its parent's
# context, so re-emitting them per spawn would pay the cost on every delegation (AC-005.4).
{
    printf '<system-reminder>\n'
    printf '[%s] session=%s agent=%s type=%s\n' \
        "$HOOK_EVENT" "$SESSION_ID" "${AGENT_ID:-n/a}" "${AGENT_TYPE:-n/a}"
    if [ "$HOOK_EVENT" = "SessionStart" ]; then
        printf 'PROJECT_NAME=%s\n' "${PROJECT_NAME:-unknown}"
        knowledge_index
    fi
    printf 'Log: logs/sessions/%s/%s\n' "$SESSION_ID" "${AGENT_ID:-}"
    printf '</system-reminder>\n'
}
