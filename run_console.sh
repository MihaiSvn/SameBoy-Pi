#!/bin/bash

echo "=== Compiling SameBoy ==="

make sdl RPI=1 -j4 

echo "=== Compiling Input Daemon ==="
mkdir -p build/bin
gcc GPIO/input_daemon.c -o build/bin/input_daemon -llgpio -O2

if [ $? -ne 0 ]; then
    echo "Error compiling the input daemon! Exiting."
    exit 1
fi

echo "=== Cleaning up old processes ==="
killall input_daemon 2>/dev/null

echo "=== Starting Input Daemon ==="
./build/bin/input_daemon &
DAEMON_PID=$!

sleep 0.5

echo "=== Starting SameBoy ==="
# If you run the script with a ROM (./run_console.sh game.gb), pass it along
ROM_PATH="$1"
if [ -z "$ROM_PATH" ]; then
    ./build/bin/SDL/sameboy
else
    ./build/bin/SDL/sameboy "$ROM_PATH"
fi

echo "=== Shutting down ==="
kill $DAEMON_PID
echo "Goodbye!"