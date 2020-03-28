#!/bin/bash
info=$(acpi -b | grep 'remaining') #acpi sometimes lists a battery that doesn't exist
[[ "$info" == *"Discharging"* ]] || exit
level=$(echo "$info" | grep -P -o '[0-9]+(?=%)')
remaining=$(echo "$info" | grep -P -o '[0-9:]{2,8} remaining')

[ "$level" -le 15 ] || exit

if [ -r "$HOME/.dbus/Xdbus" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.dbus/Xdbus"
fi
notify-send "Battery low!" "$remaining" -u critical
