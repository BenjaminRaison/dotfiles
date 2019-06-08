#!/bin/sh
# Thanks to x70b1: https://github.com/polybar/polybar-scripts/blob/master/polybar-scripts/notification-github/notification-github.sh

TOKEN="$(cat ~/.secrets/waybar-github-token)"

notifications=$(curl -fs https://api.github.com/notifications?access_token=$TOKEN | jq ".[].unread" | grep -c true)

if [ "$notifications" -gt 0 ]; then
    echo "$notifications"
else
    echo ""
fi
