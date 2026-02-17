#!/bin/bash

# Script to check error and warning count of the given log file

set -eou pipefail

LOGFILE="$HOME/log_error_detector.log"

log_message() {
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y%m%d_%H%M")
    local level=$1
    local message=$2
    echo "[$TIMESTAMP]: [$level]: ${message}" | tee -a "$LOGFILE"
}

log_error_detector() {
    local logfile=$1
    local error_count warn_count

    error_count=$(grep -ic "error" "$logfile")
    warn_count=$(grep -ic "warn" "$logfile")

    if [[ $error_count -gt 10 ]]; then
        log_message ERROR "High error count in $logfile: $error_count"
    else
        log_message INFO "Error count under control: $error_count"
    fi

    log_message INFO "Warning count: $warn_count"
}

main() {
    local logfile="${1:-}"
    if [[ -z $logfile ]]; then
        log_message ERROR "Please provide the log file."
        exit 1
    else
        log_error_detector "$logfile"
    fi
}

main "$@"