#!/bin/bash
# Script: suspend_users.sh
# Description:
#   Suspends users in parallel using the Coder CLI based on a given prefix and a numeric range.
#   The script automatically determines the proper zero-padding width from the provided range.
#   For example:
#     ./suspend_users.sh user 0001 009     --> processes users user0001 to user0009
#     ./suspend_users.sh user 1 500          --> processes users user001 to user500
#
#   It logs detailed command outputs and statuses to a main log file,
#   and records any failures to a separate failure log.
#
# Usage: ./suspend_users.sh <prefix> <lower_bound> <upper_bound>
# Example: ./suspend_users.sh user 0001 009
#
# Ensure you are logged in as an admin using the Coder CLI before running this script.

# Check for required arguments.
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <prefix> <lower_bound> <upper_bound>"
    exit 1
fi

PREFIX="$1"
LOWER_BOUND="$2"
UPPER_BOUND="$3"

# Determine the proper zero-padding width based on the maximum length of the two bounds.
width_lower=${#LOWER_BOUND}
width_upper=${#UPPER_BOUND}
if [ "$width_upper" -gt "$width_lower" ]; then
    WIDTH="$width_upper"
else
    WIDTH="$width_lower"
fi

# Convert the lower and upper bounds to numbers (base-10 to handle any leading zeros).
START=$((10#$LOWER_BOUND))
END=$((10#$UPPER_BOUND))

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
# Logs a message safely using flock to prevent concurrent write issues.
log_msg() {
    local log_file="$1"
    local msg="$2"
    (
        flock -x 200
        echo "$msg" >> "$log_file"
    ) 200>"$LOCKFILE"
}

# Function: suspend_user
# Suspends a single user by constructing the username with proper zero-padding,
# then calling the Coder CLI to suspend the user.
suspend_user() {
    local i="$1"
    # Format the user number with zero-padding as determined.
    user=$(printf "%s%0*d" "$PREFIX" "$WIDTH" "$i")
    
    # Build the suspension command.
    cmd="echo yes | coder users suspend \"$user\""
    
    # Execute the command, capturing both stdout and stderr.
    out=$(eval $cmd 2>&1)
    exit_code=$?
    
    # Construct the log message.
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

    # Log to the main command log.
    log_msg "$COMMAND_LOG" "$log_message"
    
    # For failures, also log a simplified message in the failure log.
    if [ $exit_code -ne 0 ]; then
        fail_message="FAILURE: $cmd (exit code: $exit_code)
------
"
        log_msg "$FAIL_LOG" "$fail_message"
    fi
}

# Export necessary functions and variables for parallel execution.
export PREFIX WIDTH
export COMMAND_LOG FAIL_LOG LOCKFILE
export -f log_msg
export -f suspend_user

# Suspend users in parallel from START to END.
for (( i = START; i <= END; i++ )); do
    suspend_user "$i" &
done

# Wait for all background processes to finish.
wait

echo "User suspension completed. Logs are stored in ${LOG_DIR}"

# Notify if a failure log exists and contains content.
if [ -f "$FAIL_LOG" ] && [ -s "$FAIL_LOG" ]; then
    echo "Failure log created: ${FAIL_LOG}"
fi

