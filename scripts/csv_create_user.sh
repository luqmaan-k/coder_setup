#!/bin/bash
# Script: create_users_from_csv.sh
# Description:
#   Creates users using the Coder CLI based on parameters provided in a CSV file.
#   The CSV file should have exactly three columns per line: username,email,password.
#   Lines with missing parameters are skipped and logged as failures.
#
# Usage: ./create_users_from_csv.sh <csv_file_path>
# Example: ./create_users_from_csv.sh users.csv
#
# Ensure you are logged in as an admin using the Coder CLI before running this script.

# Check for required argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <csv_file_path>"
    exit 1
fi

CSV_FILE="$1"

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File '$CSV_FILE' not found."
    exit 1
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
# Logs a message to a given log file using flock for safe concurrent writes.
log_msg() {
    local log_file="$1"
    local msg="$2"
    (
        flock -x 200
        echo "$msg" >> "$log_file"
    ) 200>"$LOCKFILE"
}

# Function: process_line
# Processes a single CSV line by creating a user via the Coder CLI.
# Parameters:
#   $1 - username
#   $2 - email
#   $3 - password
#   $4 - original CSV line (for logging)
process_line() {
    local username="$1"
    local email="$2"
    local password="$3"
    local original_line="$4"

    # Validate that all fields are non-empty.
    if [ -z "$username" ] || [ -z "$email" ] || [ -z "$password" ]; then
        log_msg "$FAIL_LOG" "Invalid line (missing parameter): $original_line"
        return 1
    fi

    # Construct the user creation command.
    cmd="coder users create --username \"$username\" --email \"$email\" --password \"$password\""

    # Execute the command, capturing output and exit code.
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

    # Log detailed output.
    log_msg "$COMMAND_LOG" "$log_message"

    # Log a simplified failure if needed.
    if [ $exit_code -ne 0 ]; then
        fail_message="FAILURE: $cmd (exit code: $exit_code)
------
"
        log_msg "$FAIL_LOG" "$fail_message"
    fi
}

export -f log_msg
export -f process_line
export COMMAND_LOG FAIL_LOG LOCKFILE

# Read the CSV file.
# If the first line is a header "username,email,password", skip it.
first_line=$(head -n 1 "$CSV_FILE")
if [[ "$first_line" == "username,email,password" ]]; then
    tail -n +2 "$CSV_FILE" | while IFS=',' read -r username email password || [ -n "$username" ]; do
        line="$username,$email,$password"
        process_line "$username" "$email" "$password" "$line" &
    done
else
    while IFS=',' read -r username email password || [ -n "$username" ]; do
        line="$username,$email,$password"
        process_line "$username" "$email" "$password" "$line" &
    done < "$CSV_FILE"
fi

# Wait for all background jobs to finish.
wait

echo "User creation from CSV completed. Logs are stored in ${LOG_DIR}"

# Notify if a failure log exists and contains content.
if [ -f "$FAIL_LOG" ] && [ -s "$FAIL_LOG" ]; then
    echo "Failure log created: ${FAIL_LOG}"
fi

