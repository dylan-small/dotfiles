#!/usr/bin/env bash
# Theme loader script for Hyprland environment
# Generates configuration files from centralized theme definitions

set -e

THEME_FILE="$HOME/.config/hypr/themes/colors.conf"
THEME_STATE_FILE="$HOME/.config/hypr/themes/.current_theme"
THEME="${1:-$(cat "$THEME_STATE_FILE" 2>/dev/null || echo "blue")}"

# Ensure theme state directory exists
mkdir -p "$(dirname "$THEME_STATE_FILE")"

# Validate theme selection
if ! grep -q "^\[$THEME\]" "$THEME_FILE"; then
    echo "Error: Theme '$THEME' not found in $THEME_FILE"
    echo "Available themes: blue, black"
    exit 1
fi

# Function to get a color value from the theme file
get_color() {
    local color_name="$1"
    awk -v theme="$THEME" -v color="$color_name" '
        /^\[.*\]/ { in_section = ($0 == "[" theme "]") }
        in_section && $1 == color {
            sub(/^[^=]*= */, "")
            sub(/ *#.*$/, "")  # Remove comments
            gsub(/^ *| *$/, "")  # Trim whitespace
            print
            exit
        }
    ' "$THEME_FILE"
}

# Function to convert rgba to hex (for CSS)
rgba_to_hex() {
    local rgba="$1"
    # Extract RRGGBB from rgba(RRGGBBaa)
    echo "$rgba" | sed -E 's/rgba\(([0-9a-f]{6})[0-9a-f]{2}\)/#\1/'
}

# Function to extract RGB values for waybar
rgba_to_rgb() {
    local rgba="$1"
    # Convert rgba(RRGGBBaa) to rgb(R, G, B)
    local hex=$(echo "$rgba" | sed -E 's/rgba\(([0-9a-f]{6})[0-9a-f]{2}\)/\1/')
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "rgb($r, $g, $b)"
}

echo "Loading theme: $THEME"

# Load all color values
BACKGROUND=$(get_color "background")
BACKGROUND_ALT=$(get_color "background_alt")
SURFACE=$(get_color "surface")
SURFACE_BRIGHT=$(get_color "surface_bright")
FOREGROUND=$(get_color "foreground")
TEXT=$(get_color "text")
TEXT_ALT=$(get_color "text_alt")
TEXT_MUTED=$(get_color "text_muted")
TEXT_BRIGHT=$(get_color "text_bright")
PRIMARY=$(get_color "primary")
SECONDARY=$(get_color "secondary")
ACCENT=$(get_color "accent")
ERROR=$(get_color "error")
WARNING=$(get_color "warning")
SUCCESS=$(get_color "success")
INFO=$(get_color "info")
BORDER_ACTIVE=$(get_color "border_active")
BORDER_INACTIVE=$(get_color "border_inactive")
SHADOW=$(get_color "shadow")
WAYBAR_BG=$(get_color "waybar_bg")
WAYBAR_BORDER=$(get_color "waybar_border")
WAYBAR_TEXT=$(get_color "waybar_text")
OPACITY_ACTIVE=$(get_color "opacity_active")
OPACITY_INACTIVE=$(get_color "opacity_inactive")

# Save current theme selection
echo "$THEME" > "$THEME_STATE_FILE"

# Generate Hyprland theme config
echo "Generating Hyprland theme configuration..."
mkdir -p "$HOME/.config/hypr/themes"
cat > "$HOME/.config/hypr/themes/theme.conf" <<EOF
# Auto-generated theme file - DO NOT EDIT MANUALLY
# Generated from: $THEME_FILE
# Active theme: $THEME
# Generated at: $(date)

general {
    col.active_border = $BORDER_ACTIVE $PRIMARY 45deg
    col.inactive_border = $BORDER_INACTIVE
}

decoration {
    shadow {
        color = $SHADOW
    }
}

# Window opacity rules
windowrulev2 = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE,class:^(kitty)$
windowrulev2 = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE,class:^(Code)$
windowrulev2 = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE,class:^(Spotify)$
windowrulev2 = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE,class:^(steam)$
EOF

# Generate Waybar CSS
echo "Generating Waybar theme..."
cat > "$HOME/.config/waybar/style.css" <<EOF
/* Auto-generated theme file - DO NOT EDIT MANUALLY */
/* Generated from: $THEME_FILE */
/* Active theme: $THEME */

* {
    border: none;
    font-family: "JetBrains Mono Nerd Font", "Font Awesome 6 Solid";
    font-size: 16px;
    min-height: 0;
    font-weight: bold;
}

window#waybar {
    background-color: transparent;
}

.modules-left {
    background-color: $(rgba_to_rgb "$WAYBAR_BG");
    border-radius: 12px;
    padding: 0 0px;
    margin: 5px 5px 5px 10px;
    border-style: solid;
    border-width: 2px;
    border-color: $(rgba_to_hex "$WAYBAR_BORDER");
}

.modules-center {
    background-color: $(rgba_to_rgb "$WAYBAR_BG");
    border-radius: 12px;
    padding: 0 10px;
    margin: 5px;
    border-style: solid;
    border-width: 2px;
    border-color: $(rgba_to_hex "$WAYBAR_BORDER");
}

.modules-right {
    background-color: $(rgba_to_rgb "$WAYBAR_BG");
    border-radius: 12px;
    padding: 0 15px;
    margin: 5px 10px 5px 0;
    border-style: solid;
    border-width: 2px;
    border-color: $(rgba_to_hex "$WAYBAR_BORDER");
}

#cpu,
#memory,
#custom-gpu,
#pulseaudio,
#battery {
    color: $(rgba_to_rgb "$WAYBAR_TEXT");
    padding: 0 8px;
}

#window {
    color: $(rgba_to_rgb "$INFO");
    padding: 0 8px;
    min-width: 5px;
}

#bluetooth,
#network {
    color: $(rgba_to_rgb "$WAYBAR_TEXT");
    padding: 0 8px;
}

#clock {
    background-color: $(rgba_to_hex "$WAYBAR_BORDER");
    border-radius: 12px;
    padding: 0 10px;
    margin: 5px;
    font-weight: bold;
    color: $(rgba_to_rgb "$TEXT_BRIGHT");
}

#bluetooth.disabled,
#network.disconnected {
    color: $(rgba_to_rgb "$ERROR");
}

#bluetooth.connected {
    color: $(rgba_to_rgb "$SUCCESS");
}

#network.wifi {
    color: $(rgba_to_rgb "$INFO");
}

#battery.warning {
    color: $(rgba_to_rgb "$WARNING");
}

#battery.critical {
    color: $(rgba_to_rgb "$ERROR");
}

#workspaces button {
    color: $(rgba_to_rgb "$SUCCESS");
    background: transparent;
    border: none;
    border-radius: 10px;
    font-family: "Nerd Font";
    background-color: $(rgba_to_hex "$WAYBAR_BORDER");
    border-radius: 12px;
    padding: 0 15px 0 15px;
    margin: 5px;
    transition: padding 0.2s ease-out;
}

#workspaces .visible {
    color: $(rgba_to_rgb "$TEXT_BRIGHT");
    background-color: $(rgba_to_hex "$SECONDARY");
    padding: 0px 25px 0px 25px;
    margin: 5px;
    transition: padding 0.3s ease-in;
}

#workspaces .urgent {
    background-color: $(rgba_to_hex "$ERROR");
    color: $(rgba_to_rgb "$TEXT_BRIGHT");
}

#custom-power {
    padding: 0 5px;
    color: $(rgba_to_rgb "$WARNING");
}

#custom-weather {
    color: $(rgba_to_rgb "$INFO");
}
EOF

# Generate Hyprlock theme
echo "Generating Hyprlock theme..."
cat > "$HOME/.config/hypr/themes/hyprlock-theme.conf" <<EOF
# Auto-generated hyprlock theme - DO NOT EDIT MANUALLY
# Generated from: $THEME_FILE
# Active theme: $THEME

# Colors are defined here and sourced by hyprlock.conf
\$background = $BACKGROUND
\$surface = $SURFACE
\$text = $TEXT
\$text_alt = $TEXT_ALT
\$primary = $PRIMARY
\$accent = $ACCENT
\$shadow = $SHADOW
EOF

echo "Theme '$THEME' loaded successfully!"
echo "Reloading Hyprland and Waybar..."

# Reload Hyprland configuration
if command -v hyprctl &> /dev/null; then
    hyprctl reload 2>/dev/null || echo "Note: Run 'hyprctl reload' to apply Hyprland changes"
fi

# Restart Waybar if running
if pgrep -x waybar > /dev/null; then
    pkill -x waybar
    sleep 0.5
    waybar &
    disown
fi

echo "Done! Theme '$THEME' is now active."
