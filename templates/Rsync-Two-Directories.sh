#!/bin/sh
#start-params
#<b>rsync file synchronization between 2 directories</b><br/>
#<br/><b>Parameters</b><br/>
#<b>#1</b> - From Direcory<br/>
#<b>#2</b> - To Directory
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

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check read access permissions on a directory
check_read_access() {
  if [ -d "$1" ]; then
    log_message "Checking read access for directory: $1"
    if [ -r "$1" ]; then
      log_message "Read access: Yes"
    else
      log_message "Read access: No"
      exit 1
    fi
  else
    log_message "Error: Directory not found."
    exit 1
  fi
}

# Function to check write access permissions on a directory
check_write_access() {
  if [ -d "$1" ]; then
    log_message "Checking write access for directory: $1"
    if [ -w "$1" ]; then
      log_message "Write access: Yes"
    else
      log_message "Write access: No"
      exit 1
    fi
  else
    log_message "Error: Directory not found."
    exit 1
  fi
}

#Check it is being run as the root user
#if [ "$(id -u)" != "0" ]; then
#   echo "This script must be run as root" 1>&2
#   exit 1
#fi

#Set properties
#--------------------------------------------------

#Start date
before="$(date +%s)"

dirName="$1"
toDirName="$2"

#current script name
me=`basename $0`
script_dir=$(dirname "$0")
#--------------------------------------------------

#From directory
fromdir="${dirName}"
#to directory
todir="${toDirName}"
#log file locatoin
logfile="${script_dir}/../logs/backup_`basename ${dirName}`.log"

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


log_message "Confirming Directory Permissions for Source Directory ${fromdir}"
check_read_access "$fromdir"
log_message "Confirming Directory Permissions for Target Directory ${todir}"
check_read_access "$todir"
check_write_access "$todir"

log_message "Checking Dependencies"

if ! command_exists rsync; then
  log_message "rsync is not installed."
  exit 2
fi


#--------------------------------------------------



#Now do the backup job writing to the log file
log_message "."
log_message "Executing background sync task [$me]"
date --iso-8601=seconds
log_message "----------------------------" 
log_message "Syncing:"
log_message "${fromdir} to ${todir}"
rsync -va "$fromdir" "$todir" 
retCode=$?
log_message "Return Code From backup is ${retCode}"
log_message "----------------------------> Completed" 
after="$(date +%s)"
elapsed_seconds="$(expr $after - $before)"
date --iso-8601=seconds
log_message Elapsed time: $elapsed_seconds secs 
log_message Completed - Elapsed time: $elapsed_seconds secs
exit $retCode;
