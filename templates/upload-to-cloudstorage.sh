#!/bin/sh
#start-params
#<b>Upload directory to cloud storage (via rclone remote).</b><br/>
#<br/><b>Parameters</b><br/>
#<b>#1</b> - Source Directory<br/>
#<b>#2</b> - Target Directory in rclone remote (e.g., remote:target/dir)
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

# Function to check if the specified rclone remote is configured
check_rclone_remote() {
  local target_path="$1"
  if ! echo "$target_path" | grep -q ":"; then
    log_message "Error: Target path must contain a colon, in the form 'remote:path'"
    exit 1
  fi
  local remote_name="${target_path%%:*}"
  if [ -z "$remote_name" ]; then
    log_message "Error: Remote name cannot be empty in target path"
    exit 1
  fi
  if ! rclone listremotes | grep -q "^${remote_name}:"; then
    log_message "Error: Remote '${remote_name}' not configured in rclone."
    exit 1
  fi
}

# Check number of arguments
if [ $# -ne 2 ]; then
  log_message "Usage: $0 <source_directory> <remote:target_directory>"
  exit 1
fi

# Set properties
#--------------------------------------------------

# Start date
before="$(date +%s)"

fromdir="$1"
todir="$2"

# Current script name
me=`basename $0`
script_dir=$(dirname "$0")
#--------------------------------------------------

# Log file location
logfile="${script_dir}/upload_`basename ${fromdir}`.log"

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

# Check if rclone is installed
if ! command_exists rclone; then
  log_message "rclone is not installed."
  exit 2
fi

# Check if the specified rclone remote is configured
check_rclone_remote "$todir"

# Check read access for fromdir
check_read_access "$fromdir"

#--------------------------------------------------

# Now do the upload job writing to the log file
log_message "."
log_message "Executing upload to rclone remote [$me]"
date --iso-8601=seconds
log_message "----------------------------" 
log_message "Uploading:"
log_message "${fromdir} to ${todir}"
rclone copy "$fromdir" "$todir"
retCode=$?
log_message "Return Code from rclone is ${retCode}"
log_message "----------------------------> Completed" 
after="$(date +%s)"
elapsed_seconds="$(expr $after - $before)"
date --iso-8601=seconds
log_message "Elapsed time: $elapsed_seconds secs"
log_message "Completed - Elapsed time: $elapsed_seconds secs"
exit $retCode
