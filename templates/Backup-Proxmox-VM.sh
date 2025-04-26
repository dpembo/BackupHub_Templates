#!/bin/bash
#start-params
#<b>Backup a Proxmox VM</b><br/>
#<br/><b>Parameters</b><br/>
#<b>#1</b> - VM id<br/>
#<b>#2</b> - Email Adress<br/>
#<b>#3</b> - Mode e.g. stop<br/>
#<b>#4</b> - Dump directory<br/>
#end-params
me=`basename $0`
script_dir=$(dirname "$0")
logfile="${script_dir}/../logs/backup_`basename ${dirName}`.log"
echo "Logging to ${logfile}"

# Function to log messages to console and the log file
# Usage: log_message "message"
log_message() {
  local message="$1"
  
  # Log to console (stdout)
  echo "$message"
  
  # Log to log file (append mode)
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$logfile"
}

job=$1
before="$(date +%s)"

log_message "***********************************************************"
log_message "$0"
log_message "***********************************************************"

log_message " "
log_message "Pre-flight checks"

log_message "Script name: $0"
log_message "Number of arguments: $#"

# Loop through all the arguments and echo them one by one
for arg in "$@"; do
  log_message "Argument: $arg"
done


log_message "."
log_message "Executing background sync task $me"
date --iso-8601=seconds
log_message "----------------------------"
log_message "Starting VM Backp for $job"


vzdump $job --compress gzip --mailto $2 --mode $3 --dumpdir $4
retCode=$?
log_message "Return Code From backup is ${retCode}"
log_message "----------------------------> Completed"
after="$(date +%s)"
elapsed_seconds="$(expr $after - $before)"
date --iso-8601=seconds >> $logfile
log_message "Elapsed time: $elapsed_seconds secs"
log_message "Completed - Elapsed time: $elapsed_seconds secs"
exit $retCode
