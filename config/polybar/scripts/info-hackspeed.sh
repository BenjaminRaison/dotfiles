#!/usr/bin/env bash

# From https://github.com/x70b1/polybar-scripts/tree/master/polybar-scripts/info-hackspeed

KEYBOARD_ID="AT Translated Set 2 keyboard"

# cpm: characters per minute
# wpm: words per minute (1 word = 5 characters)
METRIC=cpm
FORMAT=" %d $METRIC"

INTERVAL=10

# If you have a keyboard layout that is not listed here yet, create a condition
# yourself. $3 is the key index. Use `xinput test "AT Translated Set 2 keyboard"`
# to see key codes in real time.  Be sure to open a pull request for your
# layout's condition!
LAYOUT=dontcare

case "$LAYOUT" in
	dontcare) CONDITION='1'; ;; # Just register all key presses, not only letters and numbers
	*) echo "Unsupported layout \"$LAYOUT\""; exit 1; ;;
esac

# We have to account for the fact we're not listening a whole minute
multiply_by=60
divide_by=$INTERVAL

case "$METRIC" in
	wpm) divide_by=$((divide_by * 5)); ;;
	cpm) ;;
	*) echo "Unsupported metric \"$METRIC\""; exit 1; ;;
esac

hackspeed_cache="$(mktemp -p '' hackspeed_cache.XXXXX)"
trap 'rm "$hackspeed_cache"' EXIT

# Write a dot to our cache for each key press
printf '' > "$hackspeed_cache"
# shellcheck disable=SC2016
xinput test "$KEYBOARD_ID" | \
	stdbuf -o0 awk '$1 == "key" && $2 == "press" && ('"$CONDITION"') {printf "."}' >> "$hackspeed_cache" &

while true; do
	# Ask the kernel how big the file is with the command `stat`. The number we
	# get is the file size in bytes, which equals the amount of dots the file
	# contains, and hence how much keys were pressed since the file was last
	# cleared.
	lines=$(stat --format %s "$hackspeed_cache")

	# Truncate the cache file so that in the next iteration, we count only new
	# keypresses
	printf '' > "$hackspeed_cache"

	# The shell only does integer operations, so make sure to first multiply and
	# then divide
	value=$((lines * multiply_by / divide_by))

	# shellcheck disable=SC2059
	printf "$FORMAT\\n" "$value"

	sleep $INTERVAL
done
