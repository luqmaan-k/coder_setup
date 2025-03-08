#!/bin/bash
# Script: process_users_with_confirmation.sh
# Description:
#   This script processes users in parallel based on a given prefix and numeric range.
#   Before executing any commands, it shows a summary and asks for confirmation.
#   It sets up a unique logs directory, logs detailed outputs to a main log file,
#   and logs any failures to a separate failure log.
#
# Usage: ./process_users_with_confirmation.sh <prefix> <start> <end>
# Example: ./process_users_with_confirmation.sh emp 01 50
#
# NOTE: Replace the placeholder command inside process_user() with your specific command.
#
# Ensure you have any required environment set up before running this script.

# Check for required arguments.
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <prefix> <start> <end>"
    exit 1
fi

PREFIX="$1"
# Convert start and end to numbers (handling leading zeros)
START=$((10#$2))
END=$((10#$3))

# Display summary and ask for confirmation.Comment it out to skip confirmation
echo "You are about to process users from ${PREFIX}$(printf "%02d" $START) to ${PREFIX}$(printf "%02d" $END)."
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
# Logs a message to the specified log file using flock to prevent race conditions.
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
    user=$(printf "%s%02d" "$PREFIX" "$user_number")
    email="${user}@organisation.com"
    
    # Placeholder command: modify or uncomment the appropriate command for your use case.
    # For example, to create a user:
    # cmd="coder users create --username \"$user\" --email \"$email\" --password \"$email\""
    
    # Example placeholder command:
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
export PREFIX
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

