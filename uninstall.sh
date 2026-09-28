#!/system/bin/sh
# Properly deletes the module  

echo 0 > /sys/class/leds/red/brightness 2>/dev/null
echo 0 > /sys/class/leds/green/brightness 2>/dev/null
echo 0 > /sys/class/leds/blue/brightness 2>/dev/null
