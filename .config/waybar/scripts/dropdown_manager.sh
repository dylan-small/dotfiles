#!/usr/bin/env bash

LOCK_FILE="/tmp/waybar-dropdowns.lock"

close_dropdown() {
  echo "Checking for lock file: $LOCK_FILE"
  if [ -f "$LOCK_FILE" ]; then
    echo "Lock file found. Reading PGID..."
    pgid=$(cat "$LOCK_FILE")
    echo "PGID to kill: $pgid"
    echo pgrep -g $pgid
    if pgrep -g $pgid >/dev/null; then
      if pkill -g $pgid 2>/dev/null; then
        echo "Process group $pgid killed."
      else
        echo "Failed to kill process group $pgid."
      fi
    else
      echo "Process group $pgid no longer exists."
    fi
    echo "Removing lock file..."
    rm -f "$LOCK_FILE"
  else
    echo "No lock file found."
  fi
}

open_dropdown() {
  close_dropdown  # Close any existing dropdown
  echo "Opening new dropdown: $@"
  "$@" &
  echo "New dropdown PID: $!"
  pgid=$(ps -o pgid= -p "$!")
  echo "Process group ID: $pgid"
  echo "$pgid" > "$LOCK_FILE"
  echo "Lock file updated with PGID: $pgid"
}

case "$1" in
  "wifi") open_dropdown $HOME/.config/waybar/scripts/run_network_manager.sh ;;
  "bluetooth") open_dropdown $HOME/.config/waybar/scripts/run_bluetooth.sh ;;
  "close") close_dropdown ;;
  *) echo "Usage: $0 {wifi|bluetooth|close}" ;;
esac