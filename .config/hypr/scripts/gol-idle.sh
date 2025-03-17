#!/bin/bash

PROGRAM="$HOME/.config/hypr/scripts/gol_wallpaper.sh"
PGID_FILE="/tmp/gol_program.pid"
FLAG_FILE="/tmp/gol_program.flag"

case "$1" in
    idle)
        touch "$FLAG_FILE"
        $PROGRAM &
        echo $(ps -o pgid= -p "$!") > "$PGID_FILE"
        sleep 2
        rm "$FLAG_FILE"
        ;;
    resume)
        if [ ! -f "$FLAG_FILE" ]; then
            if [ -f "$PGID_FILE" ]; then
                pgid=$(cat "$PGID_FILE")
                pkill -g "$pgid"
                rm "$PGID_FILE"
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {idle|resume}"
        exit 1
        ;;
esac