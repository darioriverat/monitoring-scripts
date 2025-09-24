# Server Monitoring Scripts

This repository contains a collection of bash scripts for monitoring server performance and resource usage. The scripts collect data and store it in structured log format for analysis in organized directories.

## Scripts Overview

### 1. System Processes Monitor (`system_processes.sh`)
Captures all running processes on the system with detailed resource usage.

**Features:**
- Monitors ALL system processes
- Records individual process data (no summarization)
- Captures PID, memory %, CPU %, and full command
- Output: `/var/log/monitoring/system_processes/system_processes.log`

**Log Format:**
```
[2024-01-15 10:30:00] PID=1 MEMORY=0.1% CPU=0.0% COMMAND="/sbin/init"
[2024-01-15 10:30:00] PID=1234 MEMORY=2.5% CPU=1.2% COMMAND="/usr/sbin/apache2"
```

### 2. Disk Usage Monitor (`disk_usage.sh`)
Monitors disk usage statistics for the root filesystem.

**Features:**
- Real-time disk usage monitoring
- Detailed disk statistics (total, used, available space)
- Output: `/var/log/monitoring/disk_usage/disk_usage.log`

**Log Format:**
```
[2024-01-15 14:30:25] DISK_USAGE=45% TOTAL_SPACE=100G USED_SPACE=45G AVAILABLE_SPACE=50G
```

### 3. Custom Processes Monitor (`custom_processes.sh`)
Tracks memory and CPU usage for specific processes.

**Features:**
- Monitors specific processes (apache2, mysqld)
- Tracks memory and CPU percentages
- Output: `/var/log/monitoring/custom_processes/custom_processes.log`

**Log Format:**
```
[2024-01-15 10:30:00] PROCESS=apache2 MEMORY_USAGE=2.5% CPU_USAGE=1.2%
[2024-01-15 10:30:00] PROCESS=mysqld MEMORY_USAGE=8.3% CPU_USAGE=0.8%
```

## Directory Structure

All log files are organized in the following structure:
```
/var/log/monitoring/
├── system_processes/
│   └── system_processes.log
├── disk_usage/
│   └── disk_usage.log
└── custom_processes/
    └── custom_processes.log
```

## Installation & Setup

### 1. Create Monitoring Directory Structure
```bash
# Create the monitoring directory structure
sudo mkdir -p /var/log/monitoring/{system_processes,disk_usage,custom_processes}

# Set appropriate permissions
sudo chown root:root /var/log/monitoring
sudo chmod 755 /var/log/monitoring
```

### 2. Copy Scripts to System
```bash
# Copy all scripts to /usr/bin/ (or your preferred location)
sudo cp system_processes.sh /usr/bin/
sudo cp disk_usage.sh /usr/bin/
sudo cp custom_processes.sh /usr/bin/

# Make scripts executable
sudo chmod +x /usr/bin/system_processes.sh
sudo chmod +x /usr/bin/disk_usage.sh
sudo chmod +x /usr/bin/custom_processes.sh
```

### 3. Create Systemd Services

#### System Process Monitor Service
```bash
sudo vim /etc/systemd/system/system-process-monitor.service
```

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

#### Disk Usage Monitor Service
```bash
sudo vim /etc/systemd/system/disk-monitor.service
```

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

#### Custom Processes Monitor Service
```bash
sudo vim /etc/systemd/system/custom-processes-monitor.service
```

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

### 4. Enable and Start Services
```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable services
sudo systemctl enable system-process-monitor.service
sudo systemctl enable disk-monitor.service
sudo systemctl enable custom-processes-monitor.service

# Start services
sudo systemctl start system-process-monitor.service
sudo systemctl start disk-monitor.service
sudo systemctl start custom-processes-monitor.service
```

## Monitoring & Logs

### Check Service Status
```bash
# Check if services are running
sudo systemctl status system-process-monitor.service
sudo systemctl status disk-monitor.service
sudo systemctl status custom-processes-monitor.service

# View service logs
sudo journalctl -u system-process-monitor.service -f
sudo journalctl -u disk-monitor.service -f
sudo journalctl -u custom-processes-monitor.service -f
```

### View Log Data
```bash
# View system process data
tail -f /var/log/monitoring/system_processes/system_processes.log

# View disk usage data
tail -f /var/log/monitoring/disk_usage/disk_usage.log

# View custom processes data
tail -f /var/log/monitoring/custom_processes/custom_processes.log
```

## Log Rotation

To prevent log files from growing too large, consider setting up log rotation with monitoring pause functionality:

### 1. Create Monitoring Control Script
```bash
sudo vim /usr/bin/monitoring-control.sh
```

Add the following content:
```bash
#!/bin/bash

# Monitoring control script for log rotation
SERVICES=("system-process-monitor.service" "disk-monitor.service" "custom-processes-monitor.service")

case "$1" in
    stop)
        echo "Stopping monitoring services for log rotation..."
        for service in "${SERVICES[@]}"; do
            sudo systemctl stop "$service" 2>/dev/null || true
        done
        echo "All monitoring services stopped."
        ;;
    start)
        echo "Starting monitoring services after log rotation..."
        for service in "${SERVICES[@]}"; do
            sudo systemctl start "$service" 2>/dev/null || true
        done
        echo "All monitoring services started."
        ;;
    *)
        echo "Usage: $0 {stop|start}"
        exit 1
        ;;
esac
```

Make it executable:
```bash
sudo chmod +x /usr/bin/monitoring-control.sh
```

### 2. Create Logrotate Configuration
```bash
sudo vim /etc/logrotate.d/monitoring
```

Add the following configuration:
```
/var/log/monitoring/*/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
    prerotate
        /usr/bin/monitoring-control.sh stop
    endscript
    postrotate
        /usr/bin/monitoring-control.sh start
    endscript
}
```

### 3. Test Log Rotation
```bash
# Test the log rotation configuration
sudo logrotate -d /etc/logrotate.d/monitoring

# Force log rotation (for testing)
sudo logrotate -f /etc/logrotate.d/monitoring
```

### 4. Troubleshooting Rotation

Use the following command to check if logs have been rotated.

```shell
grep logrotate /var/log/syslog
journalctl -u logrotate.service
systemctl status logrotate.service
cat /var/lib/logrotate/status
```