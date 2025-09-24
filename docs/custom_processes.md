# Custom Processes Monitor

## Overview
The Custom Processes Monitor is a bash script that tracks memory and CPU usage for specific processes.
It can be run manually or as a systemd service for continuous monitoring.

**Log Format:**
```
[2025-09-24 22:11:27] PROCESS=apache2 MEMORY_USAGE=53.6% CPU_USAGE=0.7%
[2025-09-24 22:11:27] PROCESS=mysqld MEMORY_USAGE=39.1% CPU_USAGE=7%
```

## Script Details
- **File**: `scripts/custom_processes.sh`
- **Purpose**: Monitors customized system processes
- **Log Location**: `/var/log/monitoring/custom_processes/custom_processes.log`

## Features
- Records individual process data (no summarization)
- Captures PID, memory %, CPU %, and full command

## Usage

### Manual Execution
```bash
# Make the script executable
chmod +x scripts/custom_processes.sh

# Run the script
./scripts/custom_processes.sh
```

### Log Output Format

```
[2025-09-24 22:11:27] PROCESS=apache2 MEMORY_USAGE=53.6% CPU_USAGE=0.7%
[2025-09-24 22:11:27] PROCESS=mysqld MEMORY_USAGE=39.1% CPU_USAGE=7%
```

## Systemd Service Setup

### 1. Install the Script
```bash
# Create the monitoring directory structure
sudo mkdir -p /var/log/monitoring/custom_processes

# Set appropriate permissions
sudo chown root:root /var/log/monitoring
sudo chmod 755 /var/log/monitoring

# Copy script to system location
sudo cp scripts/custom_processes.sh /usr/bin/

# Make the script executable
sudo chmod +x /usr/bin/custom_processes.sh
```

### 2. Create Systemd Service
```bash
sudo vim /etc/systemd/system/custom-processes-monitor.service
```

### 3. Service Configuration
```properties
[Unit]
Description=Custom Processes Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash -c 'while true; do /usr/bin/custom_processes.sh; sleep 5; done'
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
sudo systemctl enable custom-processes-monitor.service

# Start the service
sudo systemctl start custom-processes-monitor.service
```

## Service Management

### Check Service Status
```bash
sudo systemctl status custom-processes-monitor.service
```

### View Service Logs
```bash
sudo journalctl -u custom-processes-monitor.service -f
```

### Stop Service
```bash
sudo systemctl stop custom-processes-monitor.service
```

### Disable Service
```bash
sudo systemctl disable custom-processes-monitor.service
```

## Monitoring Interval
The service runs every minute by default. To change the interval, modify the `sleep` value in the service configuration:
```properties
ExecStart=/bin/bash -c 'while true; do /usr/bin/custom_processes.sh; sleep 60; done'
```
This example changes the interval to 1 minutes (60 seconds).
