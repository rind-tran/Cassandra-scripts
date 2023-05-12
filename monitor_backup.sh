#!/bin/bash
# 
# Nagios plugin to check Cassandra backup.
#
# $Id: check_cas_backup_,v 1.0 2022/5/12 10:00:00 $
#
# Copyright (C) 2023  DUCTH DBA.
#

# ------------------------------ SETTINGS --------------------------------------

# Nagios plugin return values
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3


# ------------------------------ FUNCTIONS -------------------------------------
printInfo() {
    echo "Nagios plugin to check Cassandra backup"
    echo "Copyright (C) 2023  DUCTH  - DBA."
}

printVersion() {
    echo
    echo "\$Id: check_cas_backup_,v 1.0 2023/05/12 10:00:00 $"
    echo
}

printHelp()  {
	echo
	echo "usage: $0 -l [-v] [H] [V]"
	echo
	echo "This script check if backup is successful."
	echo "Successful backups have the following string: \"with status: 0\"."
	echo
	echo "   -l      location of log files"
	echo "OPTIONS:"
	echo "   -V  	 version info"
	echo "   -H  	 this help screen"
	echo
}
checkOptions() {
	while getopts "l:vHV" OPTION; do
		case $OPTION in
			l)
				LOG_FILE=$OPTARG
				;;
			H) 
				printInfo
				printHelp
				exit $STATE_UNKNOWN
				;;
			V) 
				printInfo
				printVersion
				exit $STATE_UNKNOWN
				;;
			?) 
				printInfo
				printHelp
				exit $STATE_UNKNOWN
				;;
		esac
	done

# Check if log file parameter is declared and if it exist:	
	if [ -z "$LOG_FILE" ]; then
			echo "You must specify log file (-l)!"
			printHelp
			exit 1
	fi

	
	if [ ! -f "$LOG_FILE" ]; then
			echo "$LOG_FILE not exist."
			exit 1
	fi
}
# ----------------------------- MAIN PROGRAM -----------------------------------
checkOptions $@


QUERY_RESULT=`sed 's/[^,:]*://g' /var/log/cassandra_backup.log`
while read -r line; do
  if [[ $line != 0 ]]; then
    echo "Something was wrong with the backup"
	exit $STATE_CRITICAL
  fi
done <<< $QUERY_RESULT

echo "Everything is good"
exit $STATE_OK
