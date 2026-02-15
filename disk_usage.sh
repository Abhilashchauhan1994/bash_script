#!/bin/bash
# This script checks disk usage for multiple mount and logs results

set -eou pipefail

# Variables
THRESHOLD=85
LOGFILE="disk_usage.log"
MAILTO="test@testing.com"
MAIL_SUBJECT="DISK USAGE ALERT"

# Functions
log_message() {
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y%m%d_%H%M")
    local level=$1
    local message=$2
    echo "[$TIMESTAMP] [${level}]: $message" | tee -a "$LOGFILE"
}

send_mail(){
	local body=$1
	echo "$body"| mail -s "$MAIL_SUBJECT" "$MAILTO" 
}

disk_usage() {
    local mount=$1
    local current_disk_usage
    log_message INFO "Checking disk usage for $mount"
    current_disk_usage=$(df -h "${mount}" | awk 'NR==2 {print $5}' | tr -d '%')
    if [[ $current_disk_usage -gt $THRESHOLD ]]; then
		    local alert_message="Disk usage is critical. Current usage: ${current_disk_usage}%"
        log_message ERROR "$alert_message"
        mail "$alert_message"
        return 1
    else
        local message="Disk usage for is fine. Current usage: ${current_disk_usage}%"
        log_message INFO  "$message"
        mail "$message"
        return 0
    fi
}

# main function
main() {
	local critical=0 
	mount_files=("/" "/var/log" "/tmp" "/home")
	for mount in "${mount_files[@]}"; 
	do 
	 disk_usage "$mount" || critical=1
	done
	 if [[ critical -eq 1 ]]; then
		 exit 1 2>> "$LOGFILE"
	 else
		 exit 0 1>> "$LOGFILE"
	fi
}