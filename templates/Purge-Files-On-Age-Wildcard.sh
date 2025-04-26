#!/bin/bash
#start-params
#<b>Purge Files in Directory using wildcard and age</b><br/><br/>
#<b>Parameters</b><br/>
#<b>#1</b> - Directory <i>where to delete the files</i><br/>
#<b>#2</b> - Age (days) <i>of files to delete </i><br/>
#<b>#3</b> - Wildcard <i>(optional) to match files for deletion</i><br/>
#end-params
log_message() {
  local message="$1"

  # Log to console (stdout)
  echo "$message"

  # Log to log file (append mode)
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$logfile"
}

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    log_message "Usage: $0 <directory> <number_of_days> [wildcard_pattern]"
    exit 1
fi

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

#current script name
me=$(basename "$0")
script_dir=$(dirname "$0")

directory="$1"
num_days="$2"
wildcard="$3"
logfile="$directory/prune_logs.log"

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

log_message "Confirming Directory Exists ${directory}"
if [ ! -d "$directory" ]; then
    log_message "Error: Directory '$directory' not found."
    exit 1
fi

log_message "Confirming Directory Permissions for Source Directory ${directory}"
check_read_access "$directory"
check_write_access "$directory"

# ----------------------------------------------

log_message "Starting Pruning for files in '$directory' older than $num_days days with wildcard $wildcard"

if [ -n "$wildcard" ]; then
  find "$directory" -name "$wildcard" -type f -mtime +"$num_days" -delete
else
  find "$directory" -type f -mtime +"$num_days" -delete
fi

retCode=$?
log_message "Return Code From prune is ${retCode}"
log_message "Pruned files in '$directory' older than $num_days days."

echo "Pruning completed. Check '$logfile' for details."
return $retCode

