#!/bin/bash
# Claude Code hook: keeps the Mac awake while Claude is working on a prompt.
# Usage (from hooks): keep-awake.sh start | stop   (hook JSON arrives on stdin)
ACTION="$1"
INPUT="$(cat)"

# One caffeinate per session, so parallel sessions don't stop each other.
SID="$(printf '%s' "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
[ -z "$SID" ] && SID="default"

DIR="${TMPDIR:-/tmp}/claude-keep-awake"
mkdir -p "$DIR"
PIDFILE="$DIR/$SID.pid"
MAX_SECONDS=14400   # safety cap (4h) in case a Stop event never arrives

case "$ACTION" in
  start)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then exit 0; fi
    nohup /usr/bin/caffeinate -i -t "$MAX_SECONDS" >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    ;;
  stop)
    if [ -f "$PIDFILE" ]; then
      kill "$(cat "$PIDFILE")" 2>/dev/null
      rm -f "$PIDFILE"
    fi
    ;;
esac
exit 0
