#!/bin/bash
#script to create backup dir

set -eou pipefail
#variable
LOGFILE="$HOME/auto_backup.log"
#functions
log_message(){
	local level=$1
	local message=$2
	local TIMESTAMP
	TIMESTAMP=$(date +"%Y%m%d_%H%M")
	echo "[$TIMESTAMP]: [$level]: ${message}"|tee -a "$LOGFILE"
}
create_backup() {
	local dir=$1
	local TIMESTAMP backup_dir
	TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
	backup_dir="${dir}_${TIMESTAMP}.tar.gz"
	if tar -czf "${backup_dir}" "${dir}"; then 
		log_message INFO "Created backup archive: ${backup_dir}"
	else
		log_message ERROR "Backup is not created."
		exit 1
	fi
}

main() {
	local dir_argument="${1:-}"
	if [[ -z ${dir_argument} ]]; then 
		log_message ERROR "Empty Argument. Please provide directory path."
		exit 1
	fi
	if [[ ! -d ${dir_argument} ]]; then
		log_message ERROR "Directory does not exist."
		exit 1
	fi
	create_backup "${dir_argument}"
}

main "$@"