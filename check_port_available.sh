#!/bin/bash
#script to check port availability 
set -eou pipefail 
#variable
LOGFILE="$HOME/port_availability.log"

#functions
log_message(){
	local timestamp
	local level=$1
	local message=$2
	timestamp=$(date +"%Y%m%d_%H%M")
	echo "[${timestamp}]: [${level}]: ${message}"|tee -a "$LOGFILE"
}

check_port_availability(){
	local node=$1
	local port=$2
	local user=$3
	
	if ssh "${user}@${node}" "ss -tunlp | grep -q ':\${port}'"; then
        log_message "INFO" "Port ${port} is listening on ${node}"
   else
        log_message "ERROR" "Port ${port} is not listening on ${node}"
        exit 1
   fi

}

main(){
	local node="${1:-}"
	local port="${2:-}"
	local user="${3:-}"
	
	if [[ -z ${node} ||  -z ${port} || -z ${user} ]];then
		log_message "ERROR" "Argument has not passed. Please provide argument"
		exit 1
	fi
	check_port_availability "$node" "$port" "$user"
}

main "$@"