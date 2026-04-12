#!/bin/bash

# Ensure that this is being run from the project root
if [ "$(basename $(pwd))" != "wine-merlot" ]; then
    echo "Please run this script in the project root"
    exit 1
fi

# Start Xephyr and give it some time to start
Xephyr -br -ac -noreset -screen 1440x900 -resizeable :1 &
sleep 1

# Start a persistent wineserver so closing apps doesn't tear down the session
DISPLAY=:1 "install/bin/wineserver" --persistent &
sleep 0.5

# Set the program to be displayed
DISPLAY=:1 "install/bin/wine" explorer /desktop=shell,1440x900 &

# Wait for return key to be pressed
read -p "Press any key to kill..."

# Kill the desktop and Xephyr
wineserver -k
pkill Xephyr
