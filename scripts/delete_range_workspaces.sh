#!/bin/bash
# NOTE :
# IF you want to delete workspaces based on filters refer to coders docs here https://coder.com/docs/user-guides/workspace-management#workspace-filtering 
# for proper filtering
# Example : 
# coder ls -c workspace --search "owner:username status:failed"
# to filter by username and failed filter
# note that you are required to use the filter owner:username for this script since it filters for a range

# Script: delete_user_workspaces.sh
# Description:
#   For a given user prefix and numeric range, this script:
#     - Lists all workspaces belonging to each user using coder ls with a search filter.
#     - Displays the list of workspaces to be deleted and asks for confirmation.
#     - Deletes the listed workspaces in parallel using the Coder CLI.
#     - Logs detailed command output (with a separator) to a command log.
#     - For failures, logs a simplified message to a failure log.
#
# Usage: ./delete_user_workspaces.sh <prefix> <start> <end>
# Example: ./delete_user_workspaces.sh admins 01 30
#
# Ensure you are logged in as an admin using the Coder CLI before running this script.

# Check for the required arguments.
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <prefix> <start> <end>"
    exit 1
fi

PREFIX="$1"
# Convert start and end to numbers (handling leading zeros)
START=$((10#$2))
END=$((10#$3))

# Create a unique logs directory based on the script name and current date/time.
SCRIPT_NAME=$(basename "$0" .sh)
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="logs/${SCRIPT_NAME}_${TIMESTAMP}"
mkdir -p "$LOG_DIR"

# Define log file paths.
COMMAND_LOG="${LOG_DIR}/command.log"
FAIL_LOG="${LOG_DIR}/fail.log"
LOCKFILE="${LOG_DIR}/lockfile"

# Function: log_msg
# Logs a message to the specified log file using flock to prevent race conditions.
log_msg() {
    local log_file="$1"
    local msg="$2"
    (
        flock -x 200
        echo "$msg" >> "$log_file"
    ) 200>"$LOCKFILE"
}

# Global array to hold workspaces to delete.
workspaces_to_delete=()

# Loop through each user in the specified range and build the workspace list.
for (( i = START; i <= END; i++ )); do
    username=$(printf "%s%02d" "$PREFIX" "$i")
    echo "Checking workspaces for user: $username"
    
    # Use the Coder CLI to list workspaces for this user.
    # Note: Do not use --all so that the --search filter works correctly.
    ls_output=$(coder ls -c workspace --search "owner:$username" 2>&1)
    
    # If ls_output is empty or only contains header, skip.
    if [ -z "$ls_output" ]; then
        continue
    fi

    # Remove header if present (assuming header is "WORKSPACE") and remove empty lines.
    workspaces=$(echo "$ls_output" | sed '1d' | sed '/^\s*$/d')
    
    # For each workspace in the output, confirm that it starts with the username followed by a slash.
    while read -r line; do
        ws=$(echo "$line" | xargs)
        if [[ "$ws" == "$username/"* ]]; then
            workspaces_to_delete+=("$ws")
        fi
    done <<< "$workspaces"
done

# If no workspaces found, exit.
if [ ${#workspaces_to_delete[@]} -eq 0 ]; then
    echo "No workspaces found for the specified users."
    exit 0
fi

# Show the list of workspaces that will be deleted.
echo "The following workspaces will be deleted:"
for ws in "${workspaces_to_delete[@]}"; do
    echo "  $ws"
done

# Ask for confirmation.
echo -n "Are you sure you want to delete these workspaces? [y/N]: "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Aborting deletion."
    exit 0
fi

# Function: delete_workspace
# Deletes a single workspace, logging the output and status.
delete_workspace() {
    local ws="$1"
    # Construct the deletion command (using --yes to bypass individual prompts)
    cmd="coder delete \"$ws\" --yes"
    
    # Capture output and exit code.
    out=$(eval $cmd 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_message="SUCCESS: $cmd (exit code: $exit_code)
Output:
$out
------
"
    else
        log_message="FAILURE: $cmd (exit code: $exit_code)
Output:
$out
------
"
    fi

    # Log the output.
    log_msg "$COMMAND_LOG" "$log_message"
    
    # For failures, log a simplified message.
    if [ $exit_code -ne 0 ]; then
        fail_message="FAILURE: $cmd (exit code: $exit_code)
------
"
        log_msg "$FAIL_LOG" "$fail_message"
    fi
}

# Export necessary variables and functions for parallel deletion.
export COMMAND_LOG FAIL_LOG LOCKFILE
export -f log_msg
export -f delete_workspace

# Delete each workspace in parallel.
for ws in "${workspaces_to_delete[@]}"; do
    delete_workspace "$ws" &
done

# Wait for all background processes to finish.
wait

echo "Workspace deletion completed. Logs are stored in ${LOG_DIR}"

# Notify if a failure log was created.
if [ -f "$FAIL_LOG" ]; then
    if [ -s "$FAIL_LOG" ]; then
        echo "Failure log created: ${FAIL_LOG}"
    fi
fi

