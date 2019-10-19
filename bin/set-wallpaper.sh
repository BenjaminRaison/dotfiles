#!/bin/bash
wallpaper=$(shuf -ezn 1 "$HOME"/pictures/wallpapers/* | tr '\0' '\n')
ln -sf "$wallpaper" "$HOME/pictures/wallpaper"

