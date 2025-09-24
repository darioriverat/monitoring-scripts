# Log Rotation

To prevent log files from growing too large, consider setting up log rotation with monitoring pause functionality:

## 1. Create Monitoring Control Script
```bash
sudo vim /usr/bin/monitoring-control.sh
```

Add the following content:

> [!NOTE]
> The following script allows to setup multiple monitoring script. Ensure it manages the target script(s) only.

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

## 2. Create Logrotate Configuration
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

## 3. Test Log Rotation
```bash
# Test the log rotation configuration
sudo logrotate -d /etc/logrotate.d/monitoring

# Force log rotation (for testing)
sudo logrotate -f /etc/logrotate.d/monitoring
```

## 4. Troubleshooting Rotation

Use the following command to check if logs have been rotated.

```shell
grep logrotate /var/log/syslog
journalctl -u logrotate.service
systemctl status logrotate.service
cat /var/lib/logrotate/status
```