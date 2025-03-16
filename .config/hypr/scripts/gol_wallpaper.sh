#!/bin/bash

hyprctl dispatch focusmonitor DP-2 
processing-java --sketch='/home/Dylan/sketchbook/GOL' --run &

sleep 1

hyprctl dispatch focusmonitor DP-3 
processing-java --sketch='/home/Dylan/sketchbook/GOL' --run 

