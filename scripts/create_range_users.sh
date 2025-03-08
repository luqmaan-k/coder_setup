#!/bin/bash
# Script: create_range_users.sh
# Description: Creates users in parallel using the Coder CLI.
#              Users are generated based on a given prefix and a numeric range.
#              Each user gets an email and password in the format: <username>@organisation.com.
#              Successes and failures are logged separately.
#
# Usage: ./create_range_users.sh <prefix> <start> <end>
# Example: ./create_range_users.sh admins 01 30
#
# Ensure you are logged in as an admin using the Coder CLI before running this script.

# Check for the required arguments.
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

# Function: create_user
# Creates a user for a given numeric value, logs the executed command and its success or failure.
create_user() {
    local i="$1"
    # Format the number with leading zeros (keeping two digits; adjust if needed)
    user=$(printf "%s%02d" "$PREFIX" "$i")
    email="${user}@organisation.com"
    
    # Construct the command.
    cmd="coder users create --name \"$user\" --email \"$email\" --password \"$email\""
    
    # Execute the command.
    eval $cmd
    exit_code=$?
    
    # Log the result using file locks.
    if [ $exit_code -eq 0 ]; then
        log_msg "$COMMAND_LOG" "SUCCESS: $cmd"
    else
        log_msg "$COMMAND_LOG" "FAILURE: $cmd (exit code: $exit_code)"
        log_msg "$FAIL_LOG" "FAILURE: $cmd (exit code: $exit_code)"
    fi
}

# Export functions and variables for parallel execution in subshells.
export PREFIX
export LOG_DIR COMMAND_LOG FAIL_LOG LOCKFILE
export -f log_msg
export -f create_user

# Run user creation in parallel for the given range.
for (( i = START; i <= END; i++ )); do
    create_user "$i" &
done

# Wait for all background processes to finish.
wait

echo "User creation completed. Logs are stored in ${LOG_DIR}"

