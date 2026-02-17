#!/bin/bash

# === Configuration ===
THRESHOLD=80                    # CPU usage threshold (%)
MAIL_TO="test@tesing.com"     # Email address for alert
LOG_FILE="$HOME/cpu_alert.log"
STATE_FILE="$HOME/cpu_alert_state"  # Tracks alert state
HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# === Functions ===

# Function to check required commands
check_dependencies() {
    for cmd in top awk mailx; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "$DATE - ERROR: Required command '$cmd' not found." | tee -a "$LOG_FILE"
            exit 1
        fi
    done
}
# Function to get average CPU usage across all cores
get_cpu_usage() {
    # Extract CPU usage using top command
    local usage
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    
    # Handle empty or invalid values
    if [[ -z "$usage" || "$usage" == *"e+"* ]]; then
        echo "0"
    else
        echo "${usage%.*}"  # strip decimals
    fi
}
# Function to send email alert
send_email_alert() {
    local cpu_value="$1"
    local subject="[ALERT] High CPU Usage on $HOSTNAME"
    local message="Date: $DATE
    Host: $HOSTNAME
    CPU Usage: ${cpu_value}%
    
    CPU usage has exceeded the defined threshold (${THRESHOLD}%).
    
    Please investigate running processes using:
    top, ps -eo pid,comm,pcpu --sort=-pcpu
    
    Regards,
    Monitoring Script"
    
    echo "$message" | mailx -s "$subject" "$MAIL_TO"
    echo "$DATE - EMAIL: Alert email sent to $MAIL_TO (CPU: ${cpu_value}%)" >> "$LOG_FILE"
}
# Function to send recovery email
send_recovery_email() {
    local cpu_value="$1"
    local subject="[RECOVERY] CPU Usage Normalized on $HOSTNAME"
    local message="Date: $DATE
    Host: $HOSTNAME
    CPU Usage: ${cpu_value}%
    
    CPU usage has returned to normal levels below ${THRESHOLD}%.
    
    System performance stabilized.
    
    Regards,
    Monitoring Script"
    
    echo "$message" | mailx -s "$subject" "$MAIL_TO"
    echo "$DATE - EMAIL: Recovery email sent to $MAIL_TO (CPU: ${cpu_value}%)" >> "$LOG_FILE"
}

log_message() {
    echo "$DATE - $1" | tee -a "$LOG_FILE"
}
# === Main Function ===
main() {
check_dependencies

CPU_USAGE=$(get_cpu_usage)
CPU_INT=${CPU_USAGE%.*}

if [[ ! "$CPU_INT" =~ ^[0-9]+$ ]]; then
    log_message "ERROR: Invalid CPU usage value '$CPU_INT'"
    exit 1
fi

if (( CPU_INT > THRESHOLD )); then
    # CPU high
    if [[ ! -f "$STATE_FILE" ]]; then
        log_message "ALERT: CPU usage ${CPU_INT}% > ${THRESHOLD}%. Sending alert..."
        send_email_alert "$CPU_INT"
        echo "ALERT_SENT" > "$STATE_FILE"
    else
        log_message "ALERT: CPU usage ${CPU_INT}% > ${THRESHOLD}%. Alert already sent."
    fi
else
    # CPU normal
    if [[ -f "$STATE_FILE" ]]; then
        log_message "RECOVERY: CPU usage ${CPU_INT}% < ${THRESHOLD}%. Sending recovery mail..."
        send_recovery_email "$CPU_INT"
        rm -f "$STATE_FILE"
    else
        log_message "OK: CPU usage ${CPU_INT}% within threshold (${THRESHOLD}%)"
    fi
fi
}


