#!/usr/bin/env bash

TITLE=$(hyprctl activewindow | grep -oP 'title: \K.*')

if [ -z "$TITLE" ]; then
  echo "No active window"
else
  echo "$TITLE"
fi