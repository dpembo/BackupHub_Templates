#!/bin/bash
#start-params
#<b>Issues a reboot after provided delay</b><br/>
#<b>Parameters</b><br/>
#<b>#1</b> - <i>Delay in seconds</i><br/>
#end-params
log_message() {
  local message="$1"

  # Log to console (stdout)
  echo "$message"

  # Log to log file (append mode)
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$logfile"
}

#current script name
me=`basename $0`
script_dir=$(dirname "$0")

logfile="/var/log/reboot_script.log"

echo "Logging to ${logfile}"

log_message "***********************************************************"
log_message "$0"
log_message "***********************************************************"

log_message " "
log_message "Pre-flight checks"

log_message "Script name: $0"
log_message "Number of arguments: $#"

# ----------------------------------------------

log_message "Scheduling system reboot in 30 seconds..."

# Schedule the reboot using 'at' command
echo "reboot" | at now + $1 seconds

log_message "Reboot scheduled."

log_message "Script completed. Reboot will occur in 30 seconds. Check '$logfile' for details."

