#!/usr/bin/env bash

# From https://github.com/x70b1/polybar-scripts/blob/master/polybar-scripts/isactive-bluetooth

if [ "$(systemctl is-active bluetooth.service)" = "active" ]; then
	echo ""
else
	echo '%{F#666}%{F-}'
fi
