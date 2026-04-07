#!/bin/bash

# Ensure that this is being run from the project root
if [ "$(basename $(pwd))" != "wine" ]; then
    echo "Please run this script in the project root"
    exit 1
fi

# Start Xephyr and give it some time to start
Xephyr -br -ac -noreset -screen 1024x768 -resizeable :1 &
sleep 1

# Set the program to be displayed
DISPLAY=:1 "install/bin/wine" explorer /desktop=shell,1024x768 &

# Wait for return key to be pressed
read -p "Press any key to kill..."

# Kill the desktop and Xephyr
wineserver -k
pkill Xephyr
