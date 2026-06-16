#!/bin/bash
# obs-interact-close.sh
#
# Closes the OBS "Interact" window for a browser source.
#
# Stream Deck setup:
#   1. chmod +x obs-interact-close.sh
#   2. Rename to obs-interact-close.command (Terminal will execute .command files directly)
#   3. In Stream Deck: add an "Open" action and point it at obs-interact-close.command
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
