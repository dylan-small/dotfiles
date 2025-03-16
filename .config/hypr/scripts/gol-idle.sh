#!/bin/bash

PROGRAM="$HOME/.config/hypr/scripts/gol_wallpaper.sh"
PGID_FILE="/tmp/hypridle_program.pgid"

case "$1" in
    idle)
        $PROGRAM &
        echo $(ps -o pgid= -p "$!") > "$PGID_FILE"
        ;;
    resume)
        if [ -f "$PGID_FILE" ]; then
            pgid=$(cat "$pgid_FILE")
            pkill -g "$pgid"
            rm "$pgid_FILE"
        fi
        ;;
    *)
        echo "Usage: $0 {idle|resume}"
        exit 1
        ;;
esac