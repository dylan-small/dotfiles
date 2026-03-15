#!/usr/bin/env bash
# Theme loader script for Hyprland environment
# Generates configuration files from centralized theme definitions

set -e

THEME_FILE="$HOME/.config/hypr/themes/colors.conf"
THEME_STATE_FILE="$HOME/.config/hypr/themes/.current_theme"
THEME="${1:-$(cat "$THEME_STATE_FILE" 2>/dev/null || echo "galactic")}"

# Ensure theme state directory exists
mkdir -p "$(dirname "$THEME_STATE_FILE")"

# Validate theme selection
if ! grep -q "^\[$THEME\]" "$THEME_FILE"; then
    echo "Error: Theme '$THEME' not found in $THEME_FILE"
    echo "Available themes: $(grep -oP '(?<=^\[)\w+(?=\]$)' "$THEME_FILE" | tr '\n' ' ')"
    exit 1
fi

# Parse all color values from the theme section in one pass
declare -A THEME_COLORS
while IFS='= ' read -r key value; do
    [[ -n "$key" && -n "$value" ]] && THEME_COLORS["$key"]="$value"
done < <(awk -v theme="$THEME" '
    /^\[.*\]/ { in_section = ($0 == "[" theme "]") ; next }
    in_section && /=/ {
        sub(/^ */, "")
        sub(/ *#.*$/, "")
        print
    }
    in_section && /^\[/ { exit }
' "$THEME_FILE")

get_color() {
    echo "${THEME_COLORS[$1]}"
}

# Convert rgba(RRGGBBaa) to #RRGGBB
rgba_to_hex() {
    local rgba="$1"
    echo "$rgba" | sed -E 's/rgba\(([0-9a-f]{6})[0-9a-f]{2}\)/#\1/'
}

# Convert rgba(RRGGBBaa) to rgb(R, G, B) — strips alpha
rgba_to_rgb() {
    local rgba="$1"
    local hex=$(echo "$rgba" | sed -E 's/rgba\(([0-9a-f]{6})[0-9a-f]{2}\)/\1/')
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "rgb($r, $g, $b)"
}

# Convert rgba(RRGGBBaa) to CSS rgba(R, G, B, A) — preserves alpha
rgba_to_css_rgba() {
    local rgba="$1"
    local hex=$(echo "$rgba" | sed -E 's/rgba\(([0-9a-f]{8})\)/\1/')
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    local a_dec=$((16#${hex:6:2}))
    local a=$(awk "BEGIN{printf \"%.2f\", $a_dec/255}")
    echo "rgba($r, $g, $b, $a)"
}

# Take an rgba() color and return it with a custom CSS alpha
rgba_with_alpha() {
    local rgba="$1"
    local alpha="$2"
    local hex=$(echo "$rgba" | sed -E 's/rgba\(([0-9a-f]{6})[0-9a-f]{2}\)/\1/')
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "rgba($r, $g, $b, $alpha)"
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
GRADIENT_END=$(get_color "gradient_end")
WS_ACTIVE_TEXT=$(get_color "ws_active_text")

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
windowrule = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE, match:class ^(kitty)$
windowrule = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE, match:class ^(Code)$
windowrule = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE, match:class ^(Spotify)$
windowrule = opacity $OPACITY_ACTIVE $OPACITY_INACTIVE, match:class ^(steam)$
EOF

# Generate Waybar config with computed workspace labels
echo "Generating Waybar config..."
NUM_MONITORS=$(hyprctl monitors -j 2>/dev/null | jq 'length' 2>/dev/null || echo 1)
WS_PER_MONITOR=$(awk '/split-monitor-workspaces/,/}/' "$HOME/.config/hypr/hyprland.conf" | grep -oP 'count\s*=\s*\K[0-9]+' | head -1)
WS_PER_MONITOR=${WS_PER_MONITOR:-5}
TOTAL_WS=$((NUM_MONITORS * WS_PER_MONITOR))

# Build format-icons: map raw workspace ID to per-monitor ordinal
# Contiguous blocks: monitor 0 = 1-5, monitor 1 = 6-10, etc.
FORMAT_ICONS=""
for i in $(seq 1 $TOTAL_WS); do
    ordinal=$(( ((i - 1) % WS_PER_MONITOR) + 1 ))
    [ -n "$FORMAT_ICONS" ] && FORMAT_ICONS="$FORMAT_ICONS,"
    FORMAT_ICONS="$FORMAT_ICONS
            \"$i\": \"$ordinal\""
done

cat > "$HOME/.config/waybar/config.jsonc" <<WBEOF
// Auto-generated waybar config - DO NOT EDIT MANUALLY
// Generated from: $THEME_FILE
// Active theme: $THEME
// Monitors: $NUM_MONITORS, Workspaces/monitor: $WS_PER_MONITOR
{
    "layer": "top",
    "position": "top",
    "height": 38,
    "spacing": 4,
    "modules-left": [
        "cpu",
        "custom/gpu",
        "custom/weather",
        "hyprland/window"
    ],
    "modules-center": [
        "hyprland/workspaces"
    ],
    "modules-right": [
        "pulseaudio",
        "bluetooth",
        "network",
        "clock",
        "custom/power"
    ],
    "cpu": {
        "on-click": "\$HOME/.config/waybar/scripts/dropdown_manager.sh system-monitor",
        "format": " {usage}%",
        "interval": 2,
        "tooltip": false
    },
    "memory": {
        "format": "󰆼 {used:0.1f}G",
        "interval": 5,
        "tooltip": false
    },
    "custom/gpu": {
        "exec": "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1 | awk '{print \$1\"%\"}'",
        "format": "󰢮 {}",
        "interval": 5,
        "tooltip": false
    },
    "custom/weather": {
        "exec": "\$HOME/.config/waybar/scripts/weather.sh",
        "interval": 10,
        "format": "{}",
        "tooltip": false
    },
    "hyprland/window": {
        "format": "{}",
        "max-len": 200
    },
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {$FORMAT_ICONS
        },
        "on-click": "activate",
        "persistent_workspaces": false
    },
    "clock": {
        "format": "{:%I:%M %p}",
        "tooltip": "true",
        "tooltip-format": "{:%B %d, %Y}"
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "󰖁 Muted",
        "format-icons": {
            "default": [
                "",
                "",
                ""
            ]
        },
        "on-click": "\$HOME/.config/waybar/scripts/dropdown_manager.sh sound-mixer"
    },
    "bluetooth": {
        "format": "",
        "format-disabled": "",
        "format-connected": "",
        "on-click": "\$HOME/.config/waybar/scripts/dropdown_manager.sh bluetooth"
    },
    "network": {
        "format-wifi": "",
        "format-ethernet": "󰈀",
        "format-disconnected": "󰖪",
        "tooltip-format": "{ifname}: {ipaddr}",
        "on-click": "\$HOME/.config/waybar/scripts/dropdown_manager.sh wifi"
    },
    "custom/power": {
        "format": "⏻",
        "tooltip": false,
        "on-click": "wlogout"
    }
}
WBEOF

# Generate Waybar CSS
echo "Generating Waybar theme..."
cat > "$HOME/.config/waybar/style.css" <<EOF
/* Auto-generated theme file - DO NOT EDIT MANUALLY */
/* Generated from: $THEME_FILE */
/* Active theme: $THEME */

* {
    border: none;
    font-family: "JetBrains Mono Nerd Font", "Font Awesome 6 Solid";
    font-size: 18px;
    min-height: 0;
    font-weight: bold;
}

window#waybar {
    background-color: transparent;
}

.modules-left {
    background-color: $(rgba_to_css_rgba "$WAYBAR_BG");
    border-radius: 14px;
    padding: 0 0px;
    margin: 6px 6px 6px 11px;
    border-style: solid;
    border-width: 1px;
    border-color: $(rgba_with_alpha "$WAYBAR_BORDER" "0.4");
}

.modules-center {
    background-color: $(rgba_to_css_rgba "$WAYBAR_BG");
    border-radius: 14px;
    padding: 0 2px;
    margin: 6px;
    border-style: solid;
    border-width: 1px;
    border-color: $(rgba_with_alpha "$WAYBAR_BORDER" "0.4");
}

.modules-right {
    background-color: $(rgba_to_css_rgba "$WAYBAR_BG");
    border-radius: 14px;
    padding: 0 16px;
    margin: 6px 11px 6px 0;
    border-style: solid;
    border-width: 1px;
    border-color: $(rgba_with_alpha "$WAYBAR_BORDER" "0.4");
}

#cpu,
#custom-gpu {
    color: $(rgba_to_rgb "$INFO");
    padding: 0 9px;
}

#memory,
#pulseaudio,
#battery {
    color: $(rgba_to_rgb "$WAYBAR_TEXT");
    padding: 0 9px;
}

#window {
    color: $(rgba_to_rgb "$INFO");
    padding: 0 9px;
    min-width: 5px;
}

#bluetooth,
#network {
    color: $(rgba_to_rgb "$WAYBAR_TEXT");
    padding: 0 9px;
}

#clock {
    background-color: $(rgba_with_alpha "$WAYBAR_BORDER" "0.5");
    border-radius: 14px;
    padding: 0 11px;
    margin: 6px;
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
    color: transparent;
    background-color: transparent;
    border: none;
    border-radius: 9px;
    padding: 0 9px;
    margin: 4px 2px;
    font-size: 12px;
    transition: all 0.2s ease;
    box-shadow: none;
}

#workspaces button:hover {
    color: $(rgba_to_rgb "$TEXT_ALT");
    background-color: $(rgba_with_alpha "$WAYBAR_BORDER" "0.3");
}

#workspaces .visible {
    color: $(rgba_to_rgb "$WS_ACTIVE_TEXT");
    background-image: linear-gradient(135deg, $(rgba_to_hex "$PRIMARY"), $(rgba_to_hex "$GRADIENT_END"));
    box-shadow: 0 0 9px $(rgba_with_alpha "$PRIMARY" "0.3");
}

#workspaces .urgent {
    background-color: $(rgba_to_hex "$ERROR");
    color: $(rgba_to_rgb "$TEXT_BRIGHT");
}

#custom-power {
    padding: 0 6px;
    color: $(rgba_to_rgb "$PRIMARY");
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

# Generate Kitty theme
echo "Generating Kitty theme..."
mkdir -p "$HOME/.config/kitty"

KITTY_FG=$(get_color "kitty_fg")
KITTY_BG=$(get_color "kitty_bg")
KITTY_SEL_FG=$(get_color "kitty_sel_fg")
KITTY_SEL_BG=$(get_color "kitty_sel_bg")

cat > "$HOME/.config/kitty/theme.conf" <<EOF
# Auto-generated kitty theme - DO NOT EDIT MANUALLY
# Generated from: $THEME_FILE
# Active theme: $THEME

foreground $KITTY_FG
background $KITTY_BG
selection_foreground $KITTY_SEL_FG
selection_background $KITTY_SEL_BG

color0 $(get_color "kitty_color0")
color8 $(get_color "kitty_color8")
color1 $(get_color "kitty_color1")
color9 $(get_color "kitty_color9")
color2 $(get_color "kitty_color2")
color10 $(get_color "kitty_color10")
color3 $(get_color "kitty_color3")
color11 $(get_color "kitty_color11")
color4 $(get_color "kitty_color4")
color12 $(get_color "kitty_color12")
color5 $(get_color "kitty_color5")
color13 $(get_color "kitty_color13")
color6 $(get_color "kitty_color6")
color14 $(get_color "kitty_color14")
color7 $(get_color "kitty_color7")
color15 $(get_color "kitty_color15")
EOF

# Send SIGUSR1 to kitty to live-reload config
if pgrep -x kitty > /dev/null; then
    pkill -USR1 -x kitty
fi

# Generate wlogout themed icons (recolor system Adwaita icons)
echo "Generating wlogout icons and theme..."
WLOGOUT_ICON_DIR="$HOME/.config/wlogout/icons"
mkdir -p "$WLOGOUT_ICON_DIR"
ICON_COLOR=$(rgba_to_hex "$PRIMARY")

# Source icon paths (Adwaita symbolic)
ADWAITA="/usr/share/icons/Adwaita/symbolic"
recolor_icon() {
    sed -E "s/fill=\"#[0-9a-fA-F]+\"/fill=\"$ICON_COLOR\"/g; s/fill:currentColor/fill:$ICON_COLOR/g; s/color:#[0-9a-fA-F]+/color:$ICON_COLOR/g; s/<svg /<svg width=\"256\" height=\"256\" /; s/ (width|height)=\"[0-9]+px\"//g" "$1" > "$2"
}
BREEZE="/usr/share/icons/breeze/actions/32"
recolor_icon "$ADWAITA/status/system-lock-screen-symbolic.svg" "$WLOGOUT_ICON_DIR/lock.svg"
recolor_icon "$ADWAITA/actions/system-log-out-symbolic.svg" "$WLOGOUT_ICON_DIR/logout.svg"
recolor_icon "$ADWAITA/status/weather-clear-night-symbolic.svg" "$WLOGOUT_ICON_DIR/suspend.svg"
recolor_icon "$BREEZE/system-hibernate.svg" "$WLOGOUT_ICON_DIR/hibernate.svg"
recolor_icon "$ADWAITA/actions/system-shutdown-symbolic.svg" "$WLOGOUT_ICON_DIR/shutdown.svg"
recolor_icon "$ADWAITA/actions/system-reboot-symbolic.svg" "$WLOGOUT_ICON_DIR/reboot.svg"

# Generate wlogout style
mkdir -p "$HOME/.config/wlogout"
cat > "$HOME/.config/wlogout/style.css" <<EOF
/* Auto-generated wlogout theme - DO NOT EDIT MANUALLY */
/* Generated from: $THEME_FILE */
/* Active theme: $THEME */

window {
    background-color: $(rgba_to_css_rgba "$BACKGROUND");
}

button {
    background-color: $(rgba_with_alpha "$SURFACE" "0.80");
    color: $(rgba_to_rgb "$TEXT");
    text-decoration-color: $(rgba_to_hex "$PRIMARY");
    margin: 10px;
    border-radius: 20px;
    border: 1px solid $(rgba_with_alpha "$WAYBAR_BORDER" "0.3");
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
    transition: all 0.2s ease;
    background-repeat: no-repeat;
	background-position: center;
	background-size: 25%;
    font-family: "Roboto";
    font-size: 24px;
}

button:hover {
	background-color: $(rgba_with_alpha "$SURFACE_BRIGHT" "0.90");
	border-color: $(rgba_with_alpha "$PRIMARY" "0.5");
	outline-style: none;
}

#lock {
    background-image: url("$HOME/.config/wlogout/icons/lock.svg");
}

#logout {
    background-image: url("$HOME/.config/wlogout/icons/logout.svg");
}

#suspend {
    background-image: url("$HOME/.config/wlogout/icons/suspend.svg");
}

#hibernate {
    background-image: url("$HOME/.config/wlogout/icons/hibernate.svg");
}

#shutdown {
    background-image: url("$HOME/.config/wlogout/icons/shutdown.svg");
}

#reboot {
    background-image: url("$HOME/.config/wlogout/icons/reboot.svg");
}
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
