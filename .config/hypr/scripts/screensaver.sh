#!/usr/bin/env bash
# cmatrix screensaver — spawn fullscreen cmatrix on every monitor

case "$1" in
    start)
        # Don't start if already running or locked
        pgrep -f "kitty.*CmatrixSaver" && exit 0
        pidof hyprlock && exit 0

        # Launch cmatrix on each monitor by name
        for mon in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name'); do
            hyprctl dispatch focusmonitor "$mon"
            sleep 0.1
            kitty --title "CmatrixSaver" -- cmatrix -abs &
            sleep 0.5
        done
        ;;
    stop)
        pkill -f "kitty.*CmatrixSaver" 2>/dev/null
        sleep 0.2
        ;;
esac
