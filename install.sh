#!/bin/bash
# Installs keep-awake for: Claude Code (terminal), Claude Code in the desktop app,
# and the Claude desktop app itself.   Uninstall: ./install.sh --uninstall
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK_DIR="$HOME/.claude/hooks"
HOOK="$HOOK_DIR/keep-awake.sh"
WATCHER="$HOOK_DIR/claude-app-awake.sh"
SETTINGS="$HOME/.claude/settings.json"
LABEL="com.user.claude-app-awake"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true

if [ "$1" = "--uninstall" ]; then
  [ -f "$SETTINGS" ] && osascript -l JavaScript "$HERE/merge-settings.js" "$SETTINGS" "$HOOK" uninstall
  rm -f "$PLIST" "$HOOK" "$WATCHER"
  pkill -f "caffeinate -i -t 14400" 2>/dev/null || true
  echo "Uninstalled."
  exit 0
fi

# 1) Claude Code hooks (terminal + desktop Code tab share ~/.claude/settings.json)
mkdir -p "$HOOK_DIR"
cp "$HERE/keep-awake.sh" "$HOOK"
cp "$HERE/claude-app-awake.sh" "$WATCHER"
chmod +x "$HOOK" "$WATCHER"
[ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
osascript -l JavaScript "$HERE/merge-settings.js" "$SETTINGS" "$HOOK" install

# 2) LaunchAgent for the Claude desktop app
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$WATCHER</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict>
</plist>
PLISTEOF
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "Installed. Restart any open Claude Code sessions so they pick up the hooks."
echo "Check with:  pmset -g assertions | grep caffeinate"
