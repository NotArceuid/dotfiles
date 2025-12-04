#!/bin/bash

THRESHOLD_MB=2048
MONITOR_COMMAND="mpvpaper"
CHECK_INTERVAL=300  # 5 minutes in seconds

# Function to start mpvpaper
startBg() {
    pkill -f "$MONITOR_COMMAND"
    mpvpaper -o 'no-audio --loop-playlist=inf --reset-on-next-file=all --cache=no --demuxer-max-bytes=12MiB --demuxer-max-back-bytes=128MiB --gpu-api=vulkan --hwdec=auto-safe --really-quiet' '*' ~/Pictures/Wallpapers/Animated/sk2.mp4 &
}

# Main monitoring function
monitor() {
    while true; do
        # Get total RSS in KB
        rss_total_kb=$(ps -C "$MONITOR_COMMAND" -o rss= | awk '{sum += $1} END {print sum}')
        
        if [ -n "$rss_total_kb" ] && [ "$rss_total_kb" -gt 0 ]; then
            rss_total_mb=$(( rss_total_kb / 1024 ))
            
            if [ "$rss_total_mb" -gt "$THRESHOLD_MB" ]; then
                startBg
            fi
        else
            startBg
        fi
        
        sleep "$CHECK_INTERVAL"
    done
}

# Start monitoring
monitor
