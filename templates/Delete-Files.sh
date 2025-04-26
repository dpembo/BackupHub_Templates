#!/bin/bash
#start-params
#<b>Delete Multiple Files</b><br/><br/>
#<b>Parameters</b><br/>
#<b>#1-n</b> - Filenames <i>to be deleted</i><br/>
#end-params
log_message() {
  local message="$1"

  # Log to console (stdout)
  echo "$message"

  # Log to log file (append mode)
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$logfile"
}

if [ $# -eq 0 ]; then
    log_message "Usage: $0 <file1> [<file2> ...]"
    exit 1
fi

# Function to check if a file exists
check_file_exists() {
  if [ ! -e "$1" ]; then
    log_message "Error: File '$1' not found."
    exit 1
  fi
}

#current script name
me=$(basename "$0")
script_dir=$(dirname "$0")

logfile="$script_dir/delete_files.log"

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
  check_file_exists "$arg"
done

log_message "Starting file deletion."

for file in "$@"; do
  log_message "Deleting file: $file"
  rm "$file"
  retCode=$?
  if [ $retCode -ne 0 ]; then
    log_message "Error: Failed to delete file '$file'. Exiting with return code $retCode."
    exit $retCode
  fi
done

log_message "File deletion completed successfully."
log_message "All files deleted successfully."
exit 0

