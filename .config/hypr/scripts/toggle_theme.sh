#!/usr/bin/env bash
# Cycle through blue and black themes

THEME_STATE_FILE="$HOME/.config/hypr/themes/.current_theme"
THEME_LOADER="$HOME/.config/hypr/scripts/load_theme.sh"

# Get current theme or default to blue
CURRENT_THEME=$(cat "$THEME_STATE_FILE" 2>/dev/null || echo "blue")

# Cycle to next theme
case "$CURRENT_THEME" in
    "blue")
        NEW_THEME="black"
        ;;
    "black")
        NEW_THEME="blue"
        ;;
    *)
        NEW_THEME="blue"
        ;;
esac

# Load the new theme
"$THEME_LOADER" "$NEW_THEME"

# Send notification if notify-send is available
if command -v notify-send &> /dev/null; then
    notify-send "Theme Switched" "Now using $NEW_THEME theme" -t 2000
fi
