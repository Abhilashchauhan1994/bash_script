#!/bin/bash
# this script is used for user audit

set -eou pipefail
#variables
REPORT="user_audit_report.txt" 
LOGFILE="user_audit.log"

#function
log_message(){
	local level=$1
	local message=$2
	local timestamp
	timestamp=$(date +"%Y%m%d_%H%M")
	echo "[$timestamp]: [$level]: ${message}"|tee -a "$LOGFILE"
}

user_list(){
	local get_users_list
	log_message INFO "Checking user list "
	echo "======USER LIST==================" >> $REPORT
	awk -F: '{print $1}' /etc/passwd >> $REPORT
	echo "=================================" >> $REPORT
	log_message INFO "details has been saved to $REPORT"
}

last_login_info(){
log_message INFO "Checking Last Login Details"
	 echo "===========Last Login Info===============" >> $REPORT
	 echo lastlog >> $REPORT
	 echo "==========================================" >> $REPORT
	 log_message INFO "details has been saved to $REPORT"
	}
	
password_expiry_info(){
	log_message INFO "Checking Password Expiry"
	echo "===============Checking Password Expiry==================" >> $REPORT
	for user in $(cat /etc/paaswd|awk -F: '{print$1}');
	do 
		echo "USER: $user" >> $REPORT
		sudo chage -l $user >> $REPORT 2>/dev/null|| log_message ERROR "Could not fetch expiry for $user"
	done
	echo "==========================================" >> $REPORT
	 log_message INFO "details has been saved to $REPORT"
}

check_user_group(){
	log_message INFO "Checking Users' Group"
	echo "==============Checking Users' Group====================" >> $REPORT
	for user in $(cat /etc/passwd|awk -F: '{print$1}');
	do
		echo "USER: $user" >> $REPORT
		groups $user >> $REPORT 2>/dev/null|| log_message ERROR "Could not fetch user data"
	done
	echo "==========================================" >> $REPORT
	 log_message INFO "details has been saved to $REPORT"
}

main(){
	log_message INFO "Running user audit report script"
	echo "User Account Audit Report - $(date)" > $REPORT
  echo "-----------------------------------" >> $REPORT
	user_list
	last_login_info
	password_expiry_info
	check_user_group
	echo "-----------------------------------" >> $REPORT
	log_message INFO "User audit has been completed.Please check audit report at $REPORT"
}

main