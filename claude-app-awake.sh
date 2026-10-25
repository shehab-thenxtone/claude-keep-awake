#!/bin/bash
# Keeps the Mac awake while the Claude desktop app is open (it has no hooks).
while true; do
  PID="$(pgrep -x Claude | head -n1)"
  if [ -n "$PID" ]; then
    /usr/bin/caffeinate -i -w "$PID"   # blocks until Claude.app quits
  else
    sleep 20
  fi
done
