#!/bin/bash
# network_monitor.sh
# Monitors network performance and logs issues

# Configuration
LOG_DIR="/opt/cloud/logs"
ALERT_EMAIL="admin@example.com"
INTERFACE="eth0"
THRESHOLD_PACKET_LOSS=5
THRESHOLD_LATENCY=100

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/network_monitor.log"
}

# Monitor network interface status
check_interface() {
    log "Checking interface $INTERFACE status"
    STATUS=$(ip link show $INTERFACE | grep -o "UP" || echo "DOWN")
    if [ "$STATUS" != "UP" ]; then
        log "ERROR: Interface $INTERFACE is down"
        return 1
    fi
    return 0
}

# Check packet loss to gateway
check_packet_loss() {
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    LOSS=$(ping -c 10 $GATEWAY | grep "packet loss" | awk '{print $6}' | cut -d"%" -f1)
    
    log "Packet loss to gateway: $LOSS%"
    if [ "${LOSS%.*}" -gt "$THRESHOLD_PACKET_LOSS" ]; then
        log "WARNING: High packet loss detected: $LOSS%"
        return 1
    fi
    return 0
}

# Monitor latency
check_latency() {
    LATENCY=$(ping -c 5 8.8.8.8 | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    
    log "Current latency: $LATENCY ms"
    if [ "${LATENCY%.*}" -gt "$THRESHOLD_LATENCY" ]; then
        log "WARNING: High latency detected: $LATENCY ms"
        return 1
    fi
    return 0
}

# Collect network statistics
collect_stats() {
    log "Collecting network statistics..."
    
    # Interface statistics
    netstat -i | grep $INTERFACE >> "$LOG_DIR/interface_stats.log"
    
    # Connection statistics
    netstat -an | grep ESTABLISHED | wc -l >> "$LOG_DIR/connections.log"
    
    # TCP statistics
    netstat -st >> "$LOG_DIR/tcp_stats.log"
}

# Main monitoring loop
main() {
    while true; do
        log "Starting network monitoring cycle"
        
        check_interface
        check_packet_loss
        check_latency
        collect_stats
        
        log "Monitoring cycle completed"
        sleep 300 # Wait 5 minutes before next cycle
    done
}

# Run main monitoring loop
main