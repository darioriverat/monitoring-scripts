# Disk Usage Monitor

## Overview
The Disk Usage Monitor is a bash script that monitors disk usage statistics for the root filesystem.
It can be run manually or as a systemd service for continuous monitoring.

**Log Format:**
```
[2025-09-24 21:42:47] DISK_USAGE=51% TOTAL_SPACE=7.7G USED_SPACE=3.7G AVAILABLE_SPACE=3.7G
[2025-09-24 21:43:47] DISK_USAGE=51% TOTAL_SPACE=7.7G USED_SPACE=3.7G AVAILABLE_SPACE=3.7G
```

## Script Details
- **File**: `scripts/disk_usage.sh`
- **Purpose**: Monitor and log disk usage statistics
- **Log Location**: `/var/log/monitoring/disk_usage/disk_usage.log`

## Features
- Real-time disk usage monitoring
- Detailed disk statistics (total, used, available space)

## Usage

### Manual Execution
```bash
# Make the script executable
chmod +x scripts/disk_usage.sh

# Run the script
./scripts/disk_usage.sh
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

### Log Output Format

```
[2025-09-24 21:42:47] DISK_USAGE=51% TOTAL_SPACE=7.7G USED_SPACE=3.7G AVAILABLE_SPACE=3.7G
[2025-09-24 21:43:47] DISK_USAGE=51% TOTAL_SPACE=7.7G USED_SPACE=3.7G AVAILABLE_SPACE=3.7G
```

## Systemd Service Setup

### 1. Install the Script
```bash
# Create the monitoring directory structure
sudo mkdir -p /var/log/monitoring/disk_usage

# Set appropriate permissions
sudo chown root:root /var/log/monitoring
sudo chmod 755 /var/log/monitoring

# Copy script to system location
sudo cp scripts/disk_usage.sh /usr/bin/

# Make the script executable
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
