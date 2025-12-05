#!/bin/bash

THRESHOLD_MB=2048
MONITOR_COMMAND="mpvpaper"

rss_total_kb=$(ps -C "$MONITOR_COMMAND" -o rss= | awk '{sum += $1} END {print sum}')

if [ -n "$rss_total_kb" ] && [ "$rss_total_kb" -gt 0 ]; then
    rss_total_mb=$(( rss_total_kb / 1024 ))

    if [ "$rss_total_mb" -gt "$THRESHOLD_MB" ]; then
        echo "🚨 $MONITOR_COMMAND total RSS: ${rss_total_mb}MB > ${THRESHOLD_MB}MB. restarting mpvpaper..."
        systemctl --user restart mpvpaper.service
    else
        echo "✅ $MONITOR_COMMAND total RSS: ${rss_total_mb}MB under the limit (${THRESHOLD_MB}MB)."
    fi
else
    echo "ℹ️ No process $MONITOR_COMMAND running."
fi
