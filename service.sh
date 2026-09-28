#!/system/bin/sh

# Trans flag LED: pink > blue > white > blue > pink, on repeat while awake

RED_LED="/sys/class/leds/red/brightness"
GREEN_LED="/sys/class/leds/green/brightness"
BLUE_LED="/sys/class/leds/blue/brightness"

# ---- tweak these ----
# Raw LEDs wash out pastels, so these are tuned to LOOK like the flag.
# (Exact flag colours would be pink 245 169 184 / blue 91 206 250)
PINK_R=255;  PINK_G=45;   PINK_B=100
BLUE_R=0;    BLUE_G=140;  BLUE_B=255
WHITE_R=255; WHITE_G=255; WHITE_B=255

STEPS=50        # more = smoother fade
DELAY=0.02      # seconds per step (bigger = slower)
# ---------------------

set_rgb() {
    echo "$1" > "$RED_LED" 2>/dev/null
    echo "$2" > "$GREEN_LED" 2>/dev/null
    echo "$3" > "$BLUE_LED" 2>/dev/null
}

is_awake() {
    dumpsys power 2>/dev/null | grep -q "mWakefulness=Awake"
}

# fade r1 g1 b1 r2 g2 b2
fade() {
    i=1
    while [ "$i" -le "$STEPS" ]; do
        set_rgb $(( $1 + ($4 - $1) * i / STEPS )) \
                $(( $2 + ($5 - $2) * i / STEPS )) \
                $(( $3 + ($6 - $3) * i / STEPS ))
        sleep "$DELAY"
        i=$((i + 1))
    done
}

trans_cycle() {
    while is_awake; do
        fade $PINK_R  $PINK_G  $PINK_B   $BLUE_R  $BLUE_G  $BLUE_B    # pink > blue
        is_awake || break
        fade $BLUE_R  $BLUE_G  $BLUE_B   $WHITE_R $WHITE_G $WHITE_B   # blue > white
        is_awake || break
        fade $WHITE_R $WHITE_G $WHITE_B  $BLUE_R  $BLUE_G  $BLUE_B    # white > blue
        is_awake || break
        fade $BLUE_R  $BLUE_G  $BLUE_B   $PINK_R  $PINK_G  $PINK_B    # blue > pink
    done
}

main_loop() {
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    while true; do
        if is_awake; then
            set_rgb $PINK_R $PINK_G $PINK_B
            trans_cycle
            set_rgb 0 0 0
        fi
        sleep 1
    done
}

main_loop &
