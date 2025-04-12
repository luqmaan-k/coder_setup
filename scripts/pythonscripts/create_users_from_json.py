#!/usr/bin/env python3
"""
Script: create_users_from_json.py
Description:
  Creates users using the Coder CLI based on parameters provided in a JSON file.
  The JSON file should contain a list of dictionaries with the keys:
      "username", "email", "password".
  Entries with missing parameters are skipped and logged as failures.
  
Usage:
  python create_users_from_json.py <json_file_path>
Example:
  python create_users_from_json.py users.json

Ensure you are logged in as an admin using the Coder CLI before running this script.
"""

import sys
import os
import json
import subprocess
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor

def log_message(file_path, message):
    with open(file_path, 'a') as f:
        f.write(message + "\n")

def create_user(user, command_log, fail_log):
    username = user.get("username")
    email = user.get("email")
    password = user.get("password")
    
    if not username or not email or not password:
        log_message(fail_log, f"Invalid entry (missing parameter): {user}")
        return

    cmd = ["coder", "users", "create", "--username", username, "--email", email, "--password", password]
    
    # Run command without check=True so we capture stdout and stderr in all cases.
    result = subprocess.run(cmd, capture_output=True, text=True)
    # Combine stdout and stderr, stripping extra whitespace.
    output = (result.stdout.strip() + "\n" + result.stderr.strip()).strip()
    
    if result.returncode == 0:
        msg = (f"SUCCESS: {' '.join(cmd)} (exit code: {result.returncode})\n"
               f"Output:\n{output}\n------")
        log_message(command_log, msg)
    else:
        msg = (f"FAILURE: {' '.join(cmd)} (exit code: {result.returncode})\n"
               f"Output:\n{output}\n------")
        log_message(command_log, msg)
        log_message(fail_log, f"FAILURE: {' '.join(cmd)} (exit code: {result.returncode})\n------")

def main(json_file):
    if not os.path.isfile(json_file):
        print(f"Error: File '{json_file}' not found.")
        sys.exit(1)
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
        sys.exit(1)
        
    if not isinstance(data, list):
        print("JSON file must contain a list of user dictionaries.")
        sys.exit(1)

    script_name = os.path.splitext(os.path.basename(__file__))[0]
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_dir = os.path.join('logs', f"create_users_from_json_{timestamp}")
    os.makedirs(log_dir, exist_ok=True)
    command_log = os.path.join(log_dir, 'command.log')
    fail_log = os.path.join(log_dir, 'fail.log')

    with ThreadPoolExecutor() as executor:
        futures = []
        for user in data:
            futures.append(executor.submit(create_user, user, command_log, fail_log))
        for future in futures:
            future.result()

    print(f"User creation from JSON completed. Logs are stored in {log_dir}")
    if os.path.exists(fail_log) and os.path.getsize(fail_log) > 0:
        print(f"Failure log created: {fail_log}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <json_file_path>")
        sys.exit(1)
    main(sys.argv[1])

