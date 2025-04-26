#!/bin/bash
#start-params
#<b>Mount Threshold Script:</b> Filesystem over threshold<br/>
#<br/><b>Parameters</b><br/>
#<b>#1</b> - JSON like structure for mount information. <i>Example:<br><code>{mount:/,usage:21},{mount:/init,usage:1}</code></i><br/>
#<b>#2</b> - Threshold Value Percentage. <i>e.g. 30</i>
#end-params

check_space() {
    local mount_point="$1"
    local input_usage="$2"

    # Get actual used and available space for the mount point
    space_info=$(df -h --output=used,avail "$mount_point" | tail -n 1)
    
    # Extract the used and available space values
    used=$(echo "$space_info" | awk '{print $1}')
    avail=$(echo "$space_info" | awk '{print $2}')

    # Output the results
    log_message "Mount Point : $mount_point"
    log_message "- Usage     : ${input_usage}%"
    log_message "- Used      : $used"
    log_message "- Free      : $avail"
}

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

logfile="/var/log/mount_threshold_exceeded.log"

echo "Logging to ${logfile}"

log_message "***********************************************************"
log_message "$0"
log_message "***********************************************************"

log_message " "
log_message "Pre-flight checks"

log_message "Script name: $0"
log_message "Number of arguments: $#"

# Iterate over all parameters
count=1
for param in "$@"; do
    echo "Parameter $count: $param"
    count=$((count + 1))
done

# ----------------------------------------------

log_message "One or more mounts have exceeded configured threshold"

# Input parameters
PARAM=$1
THRESHOLD=$2

formatted_param="${PARAM:1:-1}"

echo $formatted_param
# Replace '},{' with '|'
formatted_param=$(echo "$formatted_param" | sed 's/},{/|/g')

#remove start and end { }
formatted_param="${formatted_param:1:-1}"

# Remove '{mount:'
formatted_param=$(echo "$formatted_param" | sed 's/mount://g')

# Remove 'usage:'
formatted_param=$(echo "$formatted_param" | sed 's/usage://g')

# Remove '}'
#formatted_param=$(echo "$formatted_param" | sed 's/}//g')
#echo $formatted_param


# Loop through each mount-usage block separated by "|"
for pair in $(echo "$formatted_param" | tr '|' '\n'); do
    # Split the mount point and usage by ","
    mount_point=$(echo "$pair" | cut -d',' -f1)
    usage=$(echo "$pair" | cut -d',' -f2)

    # Only proceed if both mount_point and usage were extracted
    if [[ -n "$mount_point" && -n "$usage" ]]; then
        # Check if usage meets or exceeds the threshold
        if (( usage >= THRESHOLD )); then
            check_space "$mount_point" "$usage"
        fi
    fi
done

log_message "Script completed"
exit 0
