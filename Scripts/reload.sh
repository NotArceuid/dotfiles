#!/bin/sh

pkill waybar
hyprctl dispatch exec "waybar -c ~/.config/waybar/config.jsonc"
pkill gslapper
waypaper --restore
