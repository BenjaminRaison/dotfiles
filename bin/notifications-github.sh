#!/bin/sh
# Thanks to x70b1: https://github.com/polybar/polybar-scripts/blob/master/polybar-scripts/notification-github/notification-github.sh

TOKEN="$(cat ~/.secrets/waybar-github-token)"

notifications=$(curl -u "BenjaminRaison:$TOKEN" -fs https://api.github.com/notifications | jq ".[].unread" | grep -c true)

if [ "$notifications" -gt 0 ]; then
    echo " $notifications"
else
    echo ""
fi
