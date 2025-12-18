#!/bin/sh

pkill waybar
hyprctl dispatch exec "waybar -c ~/.config/waybar/waybar.jsonc"
pkill gslapper
waypaper --restore
