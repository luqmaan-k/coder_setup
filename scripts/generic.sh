#!/bin/bash
# Script: process_users_with_confirmation.sh
# Description:
#   This script processes users in parallel based on a given prefix and numeric range.
#   It automatically determines the proper zero-padding width from the provided lower and upper bounds.
#   Before executing any commands, it displays a summary of the range (using proper padding) and asks for confirmation.
#   It sets up a unique logs directory, logs detailed outputs to a main log file,
#   and logs any failures to a separate failure log.
#
# Usage: ./process_users_with_confirmation.sh <prefix> <lower_bound> <upper_bound>
# Example: ./process_users_with_confirmation.sh emp 001 050
#
# NOTE: Replace the placeholder command inside process_user() with your specific command.
#
# Ensure you have any required environment set up before running this script.

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

# Convert lower and upper bound strings to numbers (base-10 to ignore any leading zeros).
START=$((10#$LOWER_BOUND))
END=$((10#$UPPER_BOUND))

# Display summary and ask for confirmation. (Comment out these lines to skip confirmation.)
printf "You are about to process users from %s to %s.\n" \
       "$(printf "%s%0*d" "$PREFIX" "$WIDTH" "$START")" \
       "$(printf "%s%0*d" "$PREFIX" "$WIDTH" "$END")"
read -p "Do you want to proceed? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 0
fi

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
# Safely logs a message to the specified log file using flock to prevent concurrent write issues.
log_msg() {
    local log_file="$1"
    local msg="$2"
    (
        flock -x 200
        echo "$msg" >> "$log_file"
    ) 200>"$LOCKFILE"
}

# Function: process_user
# Processes a single user. Replace the placeholder command below with your specific command.
process_user() {
    local user_number="$1"
    # Format the user number with the determined zero-padding.
    user=$(printf "%s%0*d" "$PREFIX" "$WIDTH" "$user_number")
    email="${user}@organisation.com"
    
    # Placeholder command:
    # Uncomment and modify the line below to perform your actual operation, for example:
    # cmd="coder users create --username \"$user\" --email \"$email\" --password \"$email\""
    cmd="echo Processing user: $user with email: $email"
    
    # Capture command output and exit code.
    out=$(eval $cmd 2>&1)
    exit_code=$?
    
    # Build log message.
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
    
    # Log detailed output.
    log_msg "$COMMAND_LOG" "$log_message"
    
    # For failures, log a simplified message.
    if [ $exit_code -ne 0 ]; then
        fail_message="FAILURE: $cmd (exit code: $exit_code)
------
"
        log_msg "$FAIL_LOG" "$fail_message"
    fi
}

# Export necessary variables and functions for parallel execution.
export PREFIX WIDTH
export LOG_DIR COMMAND_LOG FAIL_LOG LOCKFILE
export -f log_msg
export -f process_user

# Process each user in the specified range in parallel.
for (( i = START; i <= END; i++ )); do
    process_user "$i" &
done

# Wait for all background processes to finish.
wait

echo "Processing completed. Logs are stored in ${LOG_DIR}"

# Notify if a failure log was created and has content.
if [ -f "$FAIL_LOG" ] && [ -s "$FAIL_LOG" ]; then
    echo "Failure log created: ${FAIL_LOG}"
fi

