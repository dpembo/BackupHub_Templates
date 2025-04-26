#!/bin/sh
#start-params
#<b>Backups a mysql/mariadb database using mysqldump</b><br/>
#<br/><b>Parameters</b><br/>
#<b>#1</b> - database name<br/>
#<b>#2</b> - Target Directory<br/>
#end-params

# Function to log messages to console and the log file
# Usage: log_message "message"
log_message() {
  local message="$1"
  
  # Log to console (stdout)
  echo "$message"
  
  # Log to log file (append mode)
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$logfile"
}


#Check it is being run as the root user
# if [ "$(id -u)" != "0" ]; then
#    echo "This script must be run as root" 1>&2
#    exit 1
# fi

#Set properties
#--------------------------------------------------
#Start date
before="$(date +%s)"
dbName="$1"
NOW=$(date +"%Y-%m-%d")


#current script name
me=`basename $0`
script_dir=$(dirname "$0")
#--------------------------------------------------

#to directory
todir="$1"
#--------------------------------------------------

logfile="${script_dir}/../logs/backup_DB_`basename $dbName`.log"
echo "Logging to ${logfile}"

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

log_message "Confirming Directory Permissions for Target Directory ${todir}"
check_read_access "$todir"
check_write_access "$todir"


#Now do the backup job writing to the log file
log_message "."
log_message "Executing DB Backup task $me $1"
log_message `date --iso-8601=seconds`
log_message "----------------------------"

log_message "Filename =  ${todir}/${NOW}_${1}.mysql"
mysqldump --verbose $1 > ${todir}/${NOW}_$1.mysql
retCode=$?
log_message "Return Code From backup is ${retCode}"
log_message "----------------------------> Completed" 
after="$(date +%s)"
elapsed_seconds="$(expr $after - $before)"
log_message "`date --iso-8601=seconds`"
log_message "Elapsed time: $elapsed_seconds secs"
log_message "Created File: ${todir}/${NOW}_${1}.mysql" 
log_message "Completed"
exit $retCode
