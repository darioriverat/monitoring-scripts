#!/bin/bash

# Log file path for system process data
LOG_FILE="/var/log/monitoring/system_processes/system_processes.log"

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Get all processes and append to CSV
echo "Collecting system process data at $TIMESTAMP..."

# Use ps to get all processes and format output for CSV
ps -ax -o "pid %mem %cpu command" | tail -n +2 | while read line; do
    # Parse the line to extract fields
    PID=$(echo "$line" | awk '{print $1}')
    MEM=$(echo "$line" | awk '{print $2}')
    CPU=$(echo "$line" | awk '{print $3}')
    # Command is everything after the first 3 fields
    COMMAND=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//')

    # Skip if any field is empty or invalid
    if [[ -n "$PID" && -n "$MEM" && -n "$CPU" && -n "$COMMAND" ]]; then
        echo "[$TIMESTAMP] PID=$PID MEMORY=${MEM}% CPU=${CPU}% COMMAND=\"$COMMAND\"" >> "$LOG_FILE"
    fi
done

echo "System process data logged to $LOG_FILE"
echo "Total processes recorded: $(ps -ax | wc -l)"
