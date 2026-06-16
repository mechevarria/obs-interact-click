#!/bin/bash
# obs-interact-trigger.command
#
# Stream Deck entry point: triggers the "Interact: Open Browser Source & Click"
# OBS hotkey over obs-websocket instead of a keyboard shortcut, so it works
# no matter which app/window currently has focus.
#
# Setup:
#   1. chmod +x obs-interact-trigger.command
#   2. In OBS: Tools > obs-websocket Settings, enable the WebSocket server
#   3. In Stream Deck: add an "Open" action and point it at this file
#
# Requires Node.js (uses the global WebSocket client built into Node 22+).

DIR="$(cd "$(dirname "$0")" && pwd)"
NODE="${NODE_BIN:-/opt/homebrew/bin/node}"
if [ ! -x "$NODE" ]; then
    NODE="$(command -v node)"
fi

"$NODE" "$DIR/obs-interact-trigger.mjs"

# Opening a .command file always launches Terminal — close this window
# immediately so it doesn't linger on screen after the click fires.
osascript -e 'tell application "Terminal" to close (first window whose tty is "'"$(tty)"'")' >/dev/null 2>&1 &
exit 0
