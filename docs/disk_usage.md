# Disk Usage Monitor

## Overview
The Disk Usage Monitor is a bash script that tracks disk usage statistics for the root filesystem and logs the data to a CSV file. It can be run manually or as a systemd service for continuous monitoring.

## Script Details
- **File**: `disk_usage.sh`
- **Purpose**: Monitor and log disk usage statistics
- **Output**: Console display and CSV logging
- **Log Location**: `/var/log/monitoring/disk_usage/disk_usage.csv`

## Features
- Real-time disk usage monitoring
- CSV data logging with timestamps
- Detailed disk statistics (total, used, available space)
- Automatic CSV header creation
- Console output for immediate feedback

## Usage

### Manual Execution
```bash
# Make the script executable
chmod +x disk_usage.sh

# Run the script
./disk_usage.sh
```

### Output Example
```
Timestamp: 2024-01-15 14:30:25
Disk usage: 45%
Total space: 100G
Used space: 45G
Available space: 50G
Disk usage data appended to /var/log/monitoring/disk_usage/disk_usage.csv
```

### CSV Output Format
The script creates a CSV file with the following columns:
- `Timestamp`: Date and time of the measurement
- `Disk_Usage_%`: Percentage of disk space used
- `Total_Space`: Total disk space available
- `Used_Space`: Amount of disk space currently used
- `Available_Space`: Amount of disk space available

## Systemd Service Setup

### 1. Install the Script
```bash
# Copy script to system location
sudo cp disk_usage.sh /usr/bin/disk_usage.sh
sudo chmod +x /usr/bin/disk_usage.sh
```

### 2. Create Systemd Service
```bash
sudo vim /etc/systemd/system/disk-monitor.service
```

### 3. Service Configuration
```properties
[Unit]
Description=Disk Usage Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash -c 'while true; do /usr/bin/disk_usage.sh; sleep 60; done'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 4. Enable and Start Service
```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable disk-monitor.service

# Start the service
sudo systemctl start disk-monitor.service

# Check service status
sudo systemctl status disk-monitor.service
```

## Service Management

### Check Service Status
```bash
sudo systemctl status disk-monitor.service
```

### View Service Logs
```bash
sudo journalctl -u disk-monitor.service -f
```

### Stop Service
```bash
sudo systemctl stop disk-monitor.service
```

### Disable Service
```bash
sudo systemctl disable disk-monitor.service
```

## Monitoring Interval
The service runs every minute by default. To change the interval, modify the `sleep` value in the service configuration:
```properties
ExecStart=/bin/bash -c 'while true; do /usr/bin/disk_usage.sh; sleep 600; done'
```
This example changes the interval to 10 minutes (600 seconds).

## Log File Management
The CSV log file is stored at `/var/log/monitoring/disk_usage/disk_usage.csv`. Consider implementing log rotation to prevent the file from growing too large:

```bash
# Create logrotate configuration
sudo vim /etc/logrotate.d/disk-usage
```

Add the following configuration:
```
/var/log/monitoring/disk_usage/disk_usage.csv {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
```
