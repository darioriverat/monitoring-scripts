#!/bin/bash

# Log file path
LOG_FILE="/var/log/monitoring/custom_processes/custom_processes.log"

# Array of processes to track
PROCESSES=("apache2" "mysqld")

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Loop through each process and collect metrics
for PROCESS in "${PROCESSES[@]}"; do
    # Get performance metrics for current process
    MEM_USAGE=$(ps -C "$PROCESS" -o %mem= | awk '{sum+=$1} END {print sum}')
    CPU_USAGE=$(ps -C "$PROCESS" -o %cpu= | awk '{sum+=$1} END {print sum}')

    # Display values to console
    echo "Timestamp: $TIMESTAMP"
    echo "Process: $PROCESS"
    echo "Memory usage: ${MEM_USAGE}%"
    echo "CPU usage: ${CPU_USAGE}%"
    echo "---"

    # Append data to log file
    echo "[$TIMESTAMP] PROCESS=$PROCESS MEMORY_USAGE=${MEM_USAGE}% CPU_USAGE=${CPU_USAGE}%" >> "$LOG_FILE"
done

echo "Data logged to $LOG_FILE"
