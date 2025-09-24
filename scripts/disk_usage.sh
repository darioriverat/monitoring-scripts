#!/bin/bash

# Log file path for disk usage data
LOG_FILE="/var/log/monitoring/disk_usage/disk_usage.log"

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Get disk usage for root filesystem
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# Get disk usage details
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')

# Display values to console
echo "Timestamp: $TIMESTAMP"
echo "Disk usage: ${DISK_USAGE}%"
echo "Total space: $DISK_TOTAL"
echo "Used space: $DISK_USED"
echo "Available space: $DISK_AVAILABLE"

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Append data to log file
echo "[$TIMESTAMP] DISK_USAGE=${DISK_USAGE}% TOTAL_SPACE=$DISK_TOTAL USED_SPACE=$DISK_USED AVAILABLE_SPACE=$DISK_AVAILABLE" >> "$LOG_FILE"
echo "Disk usage data logged to $LOG_FILE"
