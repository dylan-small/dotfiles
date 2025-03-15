#!/bin/bash

if pgrep -x "$1" > /dev/null; then
    pkill -x "$1"
else
    $1
fi