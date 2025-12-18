#!/bin/sh

pkill waybar
hyprctl dispatch exec "waybar -c ~/.config/waybar/waybar.jsonc"
pkill gslapper
waypaper --restore
#dir="~/.config/eww/topbar/"

# eww kill -c ~/.config/eww/topbar/
#eww daemon -c ~/.config/eww/topbar/

# ~/.config/eww/topbar/start.sh
