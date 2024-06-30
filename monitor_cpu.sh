#!/bin/bash

# Temporary file to track notified PIDs
temp_file="/tmp/notified_pids.txt"

# Ensure the temporary file exists
touch "$temp_file"

# Function to send a notification with buttons
send_notification() {
    local process_name="$1"
    local parent_name="$2"
    local pid="$3"
    
    # Use AppleScript to display a dialog with buttons
    result=$(/usr/bin/osascript <<EOF
tell application "System Events"
    display dialog "High CPU usage: $process_name (PID: $pid) spawned by $parent_name" buttons {"Terminate", "Keep"} default button "Keep"
end tell
EOF
    )

    # Check result for button pressed
    if [[ "$result" == *Terminate* ]]; then
        kill "$pid"
        echo "Requested termination of $pid - $process_name"
    fi

    echo "$pid" >> "$temp_file"  # Log this PID as notified
}

# Associative array to track continuous high CPU usage
declare -A cpu_usage_tracking

# Loop to check CPU usage every second
while true; do
    # Check for processes exceeding 80% CPU usage
    ps -A -o %cpu,ppid,pid,comm | awk '$1 >= 80 {print $2" "$3" "$4" $1}' | while read ppid pid name cpu; do
        # Initialize or increment the count of seconds above the threshold
        cpu_usage_tracking["$pid"]=$((cpu_usage_tracking["$pid"]+1))

        # Check if this PID has reached 10 seconds of high CPU usage
        if [ "${cpu_usage_tracking["$pid"]}" -ge 10 ]; then
            # Check if this PID has been notified
            if ! grep -q "^$pid$" "$temp_file"; then
                # Get the name of the parent process
                parent_name=$(ps -p $ppid -o comm=)
                send_notification "$name" "$parent_name" "$pid"
            fi
        fi
    done

    # Decrease count for any PID not currently above the threshold
    for pid in "${!cpu_usage_tracking[@]}"; do
        if ! ps -p "$pid" -o %cpu= | awk '{exit !($1 >= 80)}'; then
            cpu_usage_tracking["$pid"]=0
        fi
    done

    sleep 1
done
