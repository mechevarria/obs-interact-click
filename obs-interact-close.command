#!/bin/bash
# obs-interact-close.command
#
# Closes the OBS "Interact" window for a browser source.
#
# Stream Deck setup:
#   1. chmod +x obs-interact-close.command
#   2. In Stream Deck: add an "Open" action and point it at this file
#

osascript <<EOF
tell application "System Events"
    tell process "OBS"
        repeat with w in windows
            if name of w starts with "Interacting with " then
                click button 1 of w
                exit repeat
            end if
        end repeat
    end tell
end tell
EOF

# Opening a .command file always launches Terminal — close this window
# immediately so it doesn't linger on screen after closing Interact.
osascript -e 'tell application "Terminal" to close (first window whose tty is "'"$(tty)"'")' >/dev/null 2>&1 &
exit 0
