#!/usr/bin/env bash
# Cycle through all 14 themes
# Usage: toggle_theme.sh [--prev]

THEME_STATE_FILE="$HOME/.config/hypr/themes/.current_theme"
THEME_LOADER="$HOME/.config/hypr/scripts/load_theme.sh"

THEME_FILE="$HOME/.config/hypr/themes/colors.conf"
THEMES=($(grep -oP '(?<=^\[)\w+(?=\]$)' "$THEME_FILE"))
COUNT=${#THEMES[@]}

# Get current theme or default to galactic
CURRENT_THEME=$(cat "$THEME_STATE_FILE" 2>/dev/null || echo "galactic")

# Direction: +1 forward (default), -1 backward (--prev)
STEP=1
[[ "$1" == "--prev" ]] && STEP=$((COUNT - 1))

# Find current index and advance
NEW_THEME="${THEMES[0]}"
for i in "${!THEMES[@]}"; do
    if [[ "${THEMES[$i]}" == "$CURRENT_THEME" ]]; then
        NEXT=$(( (i + STEP) % COUNT ))
        NEW_THEME="${THEMES[$NEXT]}"
        break
    fi
done

# Load the new theme
"$THEME_LOADER" "$NEW_THEME"

# Send notification if notify-send is available
if command -v notify-send &> /dev/null; then
    notify-send "Theme Switched" "Now using $NEW_THEME theme" -t 2000
fi
