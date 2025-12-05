#!/bin/bash

# Restructure dotfiles for GNU Stow compatibility
DOTFILES="$HOME/.dotfiles"

echo "Restructuring dotfiles for Stow compatibility..."

# Create proper directory structure
declare -A structure=(
    ["fuzzel/fuzzel.ini"]=".config/fuzzel"
    ["waybar/style.css"]=".config/waybar"
    ["waybar/waybar.jsonc"]=".config/waybar"
    ["kitty/kitty.conf"]=".config/kitty"
    ["kitty/dark-theme.auto.conf"]=".config/kitty"
    ["nwg-look/config"]=".config/nwg-look"
    ["Thunar/accels.scm"]=".config/Thunar"
    ["Thunar/uca.xml"]=".config/Thunar"
    ["waypaper/config.ini"]=".config/waypaper"
    ["wayscriber/config.toml"]=".config/wayscriber"
    ["xdg-desktop-portal/hyprland-portals.conf"]=".config/xdg-desktop-portal"
    ["yazi/yazi.toml"]=".config/yazi"
)

# Process each item
for item in "${!structure[@]}"; do
    source_file="$DOTFILES/$item"
    target_dir="$DOTFILES/$(dirname $item)/${structure[$item]}"
    
    if [ -f "$source_file" ]; then
        mkdir -p "$target_dir"
        mv "$source_file" "$target_dir/"
        echo "Moved: $item → $(dirname $item)/${structure[$item]}/$(basename $item)"
    fi
done

# Handle fastfetch (copy all files)
if [ -d "$DOTFILES/fastfetch" ]; then
    mkdir -p "$DOTFILES/fastfetch/.config/fastfetch"
    find "$DOTFILES/fastfetch" -maxdepth 1 -type f | while read -r file; do
        filename=$(basename "$file")
        mv "$file" "$DOTFILES/fastfetch/.config/fastfetch/$filename"
        echo "Moved: fastfetch/$filename → fastfetch/.config/fastfetch/"
    done
fi

# Handle nvim
if [ -d "$DOTFILES/nvim" ]; then
    mkdir -p "$DOTFILES/nvim/.config/nvim"
    mv "$DOTFILES/nvim"/* "$DOTFILES/nvim/.config/nvim/" 2>/dev/null
    echo "Moved: nvim/* → nvim/.config/nvim/"
fi

echo "Done! Your dotfiles are now Stow-compatible."
echo ""
echo "New structure:"
echo "├── fuzzel/.config/fuzzel/fuzzel.ini"
echo "├── waybar/.config/waybar/{style.css,config}"
echo "├── kitty/.config/kitty/{kitty.conf,dark-theme.auto.conf}"
echo "└── etc..."
echo ""
echo "Now you can run: cd ~/.dotfiles && stow *"
