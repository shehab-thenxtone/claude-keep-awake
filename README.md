# Claude Keep Awake

Keep your Mac awake while Claude is working. The installer configures Claude Code hooks and a macOS LaunchAgent for the Claude desktop app.

## Requirements

- macOS
- Claude Code, the Claude desktop app, or both

## Install

From this directory, run:

```sh
./install.sh
```

The installer copies the hook scripts to `~/.claude/hooks`, registers hooks in `~/.claude/settings.json`, and starts a LaunchAgent for the desktop app. If settings already exist, they are backed up to a timestamped `settings.json.bak.*` file.

Restart any open Claude Code sessions after installation so they load the new hooks.

## What it does

- **Claude Code:** starts `caffeinate` when a prompt is submitted and stops it when the session stops or ends. Each session has its own process, with a four-hour safety limit.
- **Claude desktop app:** runs a background watcher that keeps the Mac awake while the app is open.

## Verify

Check for active power assertions:

```sh
pmset -g assertions | grep caffeinate
```

## Uninstall

From this directory, run:

```sh
./install.sh --uninstall
```

This removes the installed hooks and LaunchAgent and stops the Claude Code `caffeinate` processes. Your settings backup is not removed.
