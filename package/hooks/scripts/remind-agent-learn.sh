#!/bin/bash
# remind-agent-learn.sh - SubagentStop hook (phase 2: stop_hook_active=true)
# Only triggers AFTER validation. Asks the sub-agent to REPORT its learning signal, never to
# invoke $meta-learn itself: that skill runs inline in the parent session, which holds the full
# session graph and the user's approval for instruction edits.

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Only prompt for learning after validation has run (stop_hook_active=true)
if [ "$STOP_HOOK_ACTIVE" != "true" ]; then
    exit 0
fi

# Write agent-stop.jsonl (logs internally) and log the learning prompt
if [ -n "$AGENT_ID" ] && [ -d "$AGENT_LOG_DIR" ]; then
    write_agent_stop_jsonl
    log_event "AGENT_LEARN_PROMPT" "$AGENT_LOG_DIR"
fi

# Read agent start for output
read_agent_start

cat << EOF
<system-reminder>
[SubagentStop:agent-learn] session=${SESSION_ID:-unknown} agent=${AGENT_ID:-unknown} type=${AGENT_TYPE}
Started: ${AGENT_START_TIME}

LEARNING CHECK (post-validation):
If you encountered any of the following during this task:
- Errors that required debugging
- Wrong assumptions that needed correction
- Missing dependencies or unexpected behaviors
- Workarounds for undocumented issues
- Instructions that were ambiguous, conflicting, or silently wrong

Report it in your FINAL MESSAGE — do not invoke \$meta-learn yourself. That skill runs inline in
the parent session, which can see the whole session graph and holds the user's approval for
instruction edits; a sub-agent running it would analyze a graph it is itself a node of.

Report these, one line each:
- failure mode: what went wrong and where it showed
- cause: what you actually observed, not what you infer
- instruction finding: which rule/skill/agent surface allowed it, if you can name one

High signal/noise threshold: report significant failures only. Silence is a valid report.

Agent log: ${AGENT_LOG_DIR:-n/a}
Transcript: ${AGENT_TRANSCRIPT_PATH:-n/a}
</system-reminder>
EOF
