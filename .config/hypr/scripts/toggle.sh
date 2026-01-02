#!/bin/bash

process_name="$1"

if pgrep "$process_name" > /dev/null; then
    pkill "$process_name"
else
    "$@"
fi