#!/bin/bash
# Script: delete_users.sh
# Description: Deletes users in parallel using the Coder CLI.
#              Users to delete are determined by a given prefix and a numeric range.
#              The script logs command outputs and statuses (with a separator) in a main log file.
#              For failures, it logs a simplified message in a separate failure log.
#
# Usage: ./delete_users.sh <prefix> <start> <end>
# Example: ./delete_users.sh admins 01 30
#
# Ensure you are logged in as an admin using the Coder CLI before running this script.

# Check for required arguments.
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <prefix> <start> <end>"
    exit 1
fi

PREFIX="$1"
# Convert start and end to numbers (using base-10 to handle leading zeros)
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

# Function: delete_user
# Deletes a user based on the given numeric value, logs the executed command and its output.
delete_user() {
    local i="$1"
    # Format the number with leading zeros (keeping two digits; adjust if needed)
    user=$(printf "%s%02d" "$PREFIX" "$i")
    
    # Construct the deletion command using the Coder CLI.
    cmd="coder users delete \"$user\""
    
    # Capture command output (both stdout and stderr) and exit code.
    out=$(eval $cmd 2>&1)
    exit_code=$?
    
    # Build the log message for the main command log.
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
    
    # For failures, log a simplified message in the failure log.
    if [ $exit_code -ne 0 ]; then
        fail_message="FAILURE: $cmd (exit code: $exit_code)
------
"
        log_msg "$FAIL_LOG" "$fail_message"
    fi
}

# Export functions and variables for parallel execution in subshells.
export PREFIX
export LOG_DIR COMMAND_LOG FAIL_LOG LOCKFILE
export -f log_msg
export -f delete_user

# Run user deletion in parallel for the given range.
for (( i = START; i <= END; i++ )); do
    delete_user "$i" &
done

# Wait for all background processes to finish.
wait

echo "User deletion completed. Logs are stored in ${LOG_DIR}"

# Notify if a failure log was created.
if [ -f "$FAIL_LOG" ]; then
    echo "Failure log created: ${FAIL_LOG}"
fi

