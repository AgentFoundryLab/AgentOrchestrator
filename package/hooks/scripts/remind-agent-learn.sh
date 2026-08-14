#!/bin/bash
# remind-agent-learn.sh - SubagentStop hook (phase 2: stop_hook_active=true)
# Only triggers AFTER validation, prompts the agent to invoke $meta-learn

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

Consider invoking \$meta-learn to analyze the session and capture:
- failure mode: what went wrong and where it showed
- cause: root-cause analysis from the session transcript
- instruction finding: which rule/skill/agent surface allowed it
- fix: the proposed REPHRASE/ADD/DROP, applied only on approval

High signal/noise threshold: Only analyze significant failures.

Agent log: ${AGENT_LOG_DIR:-n/a}
Transcript: ${AGENT_TRANSCRIPT_PATH:-n/a}
</system-reminder>
EOF
