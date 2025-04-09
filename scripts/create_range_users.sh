#!/bin/bash
# Script: create_users.sh
# Description: Creates users in parallel using the Coder CLI.
#              Users are generated based on a given prefix and a numeric range.
#              Each user gets an email and password in the format: <username>@psgtech.ac.in.
#              The script logs command outputs and statuses (with a separator) in a main log file.
#              For failures, it logs a simplified message in a separate failure log.
#
# Usage: ./create_users.sh <prefix> <lower_bound> <upper_bound>
# Example: ./create_users.sh admins 001 030
#
# Ensure you are logged in as an admin using the Coder CLI before running this script.

# Check for the required arguments.
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

# Convert lower and upper bound strings to numbers (ignoring leading zeros).
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
# Creates a user for a given numeric value, logs the executed command and its output.
create_user() {
    local i="$1"
    # Format the user number using the calculated width.
    user=$(printf "%s%0*d" "$PREFIX" "$WIDTH" "$i")
    email="${user}@psgtech.ac.in"

    # Construct the command.
    # Note: Using --username as per the CLI documentation.
    cmd="coder users create --username \"$user\" --email \"$email\" --password \"$email\""

    # Capture command output (both stdout and stderr) and exit code.
    out=$(eval $cmd 2>&1)
    exit_code=$?

    # Build the log message for the command log.
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

    # Log to command log.
    log_msg "$COMMAND_LOG" "$log_message"

    # For failures, also log a simplified message in the failure log.
    if [ $exit_code -ne 0 ]; then
        fail_message="FAILURE: $cmd (exit code: $exit_code)
------
"
        log_msg "$FAIL_LOG" "$fail_message"
    fi
}

# Export functions and variables for parallel execution in subshells.
export PREFIX WIDTH
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

# Notify if a failure log was created.
if [ -f "$FAIL_LOG" ]; then
    echo "Failure log created: ${FAIL_LOG}"
fi

