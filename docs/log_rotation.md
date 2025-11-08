# Log Rotation

To prevent log files from growing too large, consider setting up log rotation with monitoring pause functionality:

## 1. Create Monitoring Control Script

A single script to start and stop all monitoring services helps simplify management and prevents log loss.

```bash
sudo vim /usr/bin/monitoring-control.sh
```

> [!NOTE]
> The following script allows you to set up multiple monitoring scripts. Make sure it manages only the intended target script(s).

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

## 4. Frequent Log Rotation with Cron

For scenarios where you need to compress and transfer log files more frequently (e.g., every 15 minutes), you can force logrotate to run via cron job. This leverages the existing logrotate configuration while providing more frequent rotation:

### Set Up Cron Job

Add a cron job to force logrotate execution every 15 minutes:

```bash
sudo vim /etc/crontab
```

Add the following line:
```
# Force logrotate every 15 minutes for monitoring logs
*/15 * * * * /usr/sbin/logrotate -f /etc/logrotate.d/monitoring >> /var/log/monitoring-rotation.log 2>&1
```

### Alternative Intervals

You can adjust the frequency based on your needs:

```bash
# Every 5 minutes
*/5 *     * * *   root    /usr/sbin/logrotate -f /etc/logrotate.d/monitoring >> /var/log/monitoring-rotation.log 2>&1

# Every 30 minutes
*/30 *     * * *   root    /usr/sbin/logrotate -f /etc/logrotate.d/monitoring >> /var/log/monitoring-rotation.log 2>&1

# Every hour
0 *     * * *   root    /usr/sbin/logrotate -f /etc/logrotate.d/monitoring >> /var/log/monitoring-rotation.log 2>&1
```

You can check the syntax of the crontab by executing

```bash
sudo crontab -u root /etc/crontab
```

### Monitor Cron Execution

Check if the cron job is running:
```bash
# View cron logs
tail -f /var/log/monitoring-rotation.log

# Check cron service status
systemctl status cron
```

### Benefits of Using logrotate with -f

- **Leverages existing configuration**: Uses the same logrotate setup with prerotate/postrotate scripts
- **Consistent behavior**: Same compression, rotation, and service management as daily rotation
- **No code duplication**: Reuses the monitoring control script for service management
- **Standard tooling**: Uses the system's built-in logrotate instead of custom scripts

## 5. Troubleshooting Rotation

Use the following command to check if logs have been rotated.

```shell
grep logrotate /var/log/syslog
journalctl -u logrotate.service
systemctl status logrotate.service
cat /var/lib/logrotate/status
```