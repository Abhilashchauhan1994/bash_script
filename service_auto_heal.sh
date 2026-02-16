#!/bin/bash

#this script is used to restart given service if service not running then this will start that service

set -eou pipefail

#Function
LOGFILE="/var/log/autoheal.log"
log_message(){
	local TIMESTAMP
    TIMESTAMP=$(date +"%Y%m%d_%H%M")
	local level=$1
	local message=$2
	echo "$TIMESTAMP: [$level]: $message"|tee -a "$LOGFILE"
}
check_service_status(){
	local service=$1
	if ! systemctl is-active --quiet "$service"; then
		log_message ERROR "$service is not running... Starting service now"
		systemctl restart "$service"
		if systemctl is-active --quiet "$service"; then
		log_message INFO "$service is active now."
		else
		log_message ERROR "Failed to start ${service}. Please check manually."
		fi
	fi	  
}
main(){
	local service="${1:-}"
	if [[ -z $service ]]; then
		log_message ERROR "Please pass service as an argument"
	else
		check_service_status "$service" 
	fi
}