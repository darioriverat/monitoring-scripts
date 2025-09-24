# System Processes Monitor

## Overview
The System Processes Monitor is a bash script that captures all running processes on the system with detailed resource usage.
It can be run manually or as a systemd service for continuous monitoring.

**Log Format:**
```
[2024-01-15 10:30:00] PID=1 MEMORY=0.1% CPU=0.0% COMMAND="/sbin/init"
[2024-01-15 10:30:00] PID=1234 MEMORY=2.5% CPU=1.2% COMMAND="/usr/sbin/apache2"
```

## Script Details
- **File**: `scripts/system_processes.sh`
- **Purpose**: Monitors ALL system processes
- **Log Location**: `/var/log/monitoring/system_processes/system_processes.log`

## Features
- Records individual process data (no summarization)
- Captures PID, memory %, CPU %, and full command

## Usage

### Manual Execution
```bash
# Make the script executable
chmod +x scripts/system_processes.sh

# Run the script
./scripts/system_processes.sh
```

### Log Output Format

```
[2024-01-15 10:30:00] PID=1 MEMORY=0.1% CPU=0.0% COMMAND="/sbin/init"
[2024-01-15 10:30:00] PID=1234 MEMORY=2.5% CPU=1.2% COMMAND="/usr/sbin/apache2"
```

## Systemd Service Setup

### 1. Install the Script
```bash
# Create the monitoring directory structure
sudo mkdir -p /var/log/monitoring/system_processes

# Set appropriate permissions
sudo chown root:root /var/log/monitoring
sudo chmod 755 /var/log/monitoring

# Copy script to system location
sudo cp scripts/system_processes.sh /usr/bin/

# Make the script executable
sudo chmod +x /usr/bin/system_processes.sh
```

### 2. Create Systemd Service
```bash
sudo vim /etc/systemd/system/system-process-monitor.service
```

### 3. Service Configuration
```properties
[Unit]
Description=System Process Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash -c 'while true; do /usr/bin/system_processes.sh; sleep 5; done'
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
sudo systemctl enable system-process-monitor.service

# Start the service
sudo systemctl start system-process-monitor.service
```

## Service Management

### Check Service Status
```bash
sudo systemctl status system-process-monitor.service
```

### View Service Logs
```bash
sudo journalctl -u system-process-monitor.service -f
```

### Stop Service
```bash
sudo systemctl stop system-process-monitor.service
```

### Disable Service
```bash
sudo systemctl disable system-process-monitor.service
```

## Monitoring Interval
The service runs every minute by default. To change the interval, modify the `sleep` value in the service configuration:
```properties
ExecStart=/bin/bash -c 'while true; do /usr/bin/system_processes.sh; sleep 60; done'
```
This example changes the interval to 1 minutes (60 seconds).
