#!/bin/bash
#this script delete older files 
set -eou pipefail
#Variable
LOGFILE="file_cleanup.log"

#functions
log_message(){
	local level=$1
	local message=$2
	local TIMESTAMP
	TIMESTAMP=$(date +"%Y%m%d_%H%M")
	echo "[$TIMESTAMP]: [$level]: ${message}"|tee -a "$LOGFILE"
}

file_cleanup(){
	local dir=$1
	local days=$2
	local files_count
	files_count=$(find "${dir}" -type f -name "*.log" -mtime +"${days}" | wc -l)
	log_message "INFO" "We are deleting files from $dir that are older than ${days} days"
	if [[ $files_count -eq 0 ]]; then
		log_message "ERROR" "No files found older than ${days} days in ${dir}"
	else
		find "${dir}" -type f -name "*.log" -mtime +"${days}" -ok rm {} + # ok to ask user before delete
		log_message "INFO" "We have deleted ${files_count} files from ${dir}"
	fi	
}

main() {
    local path="${1:-}"
    local old_days="${2:-}"
    if [[ -z $path || -z $old_days ]]; then
        log_message "ERROR" "Empty Arguments"
        exit 1
    fi
    if [[ ! -d $path ]]; then
        log_message "ERROR" "Path does not exist. Please check folder path."
        exit 1
    fi
    file_cleanup "$path" "$old_days"
}

main "$@"