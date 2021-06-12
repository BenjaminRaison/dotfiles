#!/bin/bash

# Originally from github:jessfraz/dotfiles

# Load .bashrc and other files...
for file in ~/.{bashrc,bash_prompt,aliases,functions,path,dockerfunc,extra,exports}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done
unset file

if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi

