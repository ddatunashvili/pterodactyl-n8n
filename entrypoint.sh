#!/bin/bash
cd /home/container || exit 1

# n8n keeps everything (SQLite database, encryption key, settings) under
# $N8N_USER_FOLDER/.n8n, which is the server volume.
export N8N_PORT="${SERVER_PORT:-5678}"
[ -n "${N8N_HOST:-}" ] || unset N8N_HOST
[ -n "${WEBHOOK_URL:-}" ] || unset WEBHOOK_URL
export TZ="${GENERIC_TIMEZONE:-UTC}"

# Pterodactyl startup: {{VAR}} -> ${VAR}. The string is run as a script, not
# expanded through `eval echo` first: the panel may prefix it with commands of
# its own (a console banner), and `eval echo` would run those inside a command
# substitution and hand their output back as the command to execute.
MODIFIED_STARTUP=$(printf '%s' "${STARTUP:-n8n start}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Own session, so shutdown can signal bash and n8n together.
setsid bash -c "${MODIFIED_STARTUP}" </dev/null &
PID=$!

shutdown() {
    echo "Stopping n8n..."
    kill -TERM -- "-$PID" 2>/dev/null || kill -TERM "$PID" 2>/dev/null
    wait "$PID"
    exit $?
}
trap shutdown INT TERM

# The container lives exactly as long as n8n does: one that fails to start
# must exit, or Wings shows "starting" for ever.
wait "$PID"
exit $?
