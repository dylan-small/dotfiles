#!/usr/bin/env bash
# ~/.config/hypr/scripts/load-theme

THEME_FILE="$HOME/.config/hypr/themes/colors.conf"
TARGET_THEME="${1:-dark}"  # Default to dark theme if no argument provided

# Function to extract a color value from the theme file
get_color() {
    local color_name=$1
    grep -oP "(?<=$color_name = ).*" "$THEME_FILE" | sed -n "/^\[colors:$TARGET_THEME\]/,/^\[/p" | grep "$color_name" | head -n 1
}

# Read all colors
WALLPAPER=$(get_color "wallpaper")
BACKGROUND=$(get_color "background")
BACKGROUND_ALT=$(get_color "background-alt")
FOREGROUND=$(get_color "foreground")
PRIMARY=$(get_color "primary")
SECONDARY=$(get_color "secondary")
ACCENT=$(get_color "accent")
TEXT=$(get_color "text")
TEXT_ALT=$(get_color "text-alt")
ERROR=$(get_color "error")
WARNING=$(get_color "warning")

# Export variables for use in other scripts
export WALLPAPER BACKGROUND BACKGROUND_ALT FOREGROUND PRIMARY SECONDARY ACCENT TEXT TEXT_ALT ERROR WARNING

# Generate Hyprland color config
mkdir -p ~/.config/hypr/themes/generated
cat > ~/.config/hypr/themes/generated/hyprland-colors.conf <<EOF
# Generated colors - do not edit directly
general {
    col.active_border = $PRIMARY $SECONDARY 45deg
    col.inactive_border = $BACKGROUND_ALT
}

decoration {
    col.shadow = $BACKGROUND
    col.shadow_inactive = $BACKGROUND_ALT
}

layerrule = blur,waybar
EOF

# Generate Waybar style.css
cat > ~/.config/waybar/style.css <<EOF
/* Generated colors - do not edit directly */
@define-color background ${BACKGROUND};
@define-color background-alt ${BACKGROUND_ALT};
@define-color foreground ${FOREGROUND};
@define-color primary ${PRIMARY};
@define-color secondary ${SECONDARY};
@define-color accent ${ACCENT};
@define-color text ${TEXT};
@define-color text-alt ${TEXT_ALT};
@define-color error ${ERROR};
@define-color warning ${WARNING};

* {
    border: none;
    font-family: "FiraCode Nerd Font";
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: @define-color background;
    color: @define-color text;
}
/* ... rest of your waybar CSS ... */
EOF

# Generate hyprlock config
cat > ~/.config/hypr/hyprlock.conf <<EOF
# Generated colors - do not edit directly
background {
    monitor =
    path = $WALLPAPER
    blur_passes = 3
}

input-field {
    monitor =
    size = 250, 50
    outline_thickness = 3
    dots_size = 0.2
    dots_spacing = 0.2
    dots_center = true
    outer_color = $BACKGROUND
    inner_color = $BACKGROUND_ALT
    font_color = $TEXT
    fade_on_empty = true
    placeholder_text = <span foreground="##${TEXT_ALT:5:6}">Password...</span>
}

label {
    monitor =
    text = cmd[update:1000] echo "<span foreground='$PRIMARY'>$(date +'%H:%M')</span>"
    color = $TEXT
    font_size = 64
    font_family = FiraCode Nerd Font
    position = 0, 80
    halign = center
    valign = center
}
EOF