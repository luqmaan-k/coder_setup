#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <roll_number_prefix> <start_number> <end_number>"
    echo "Example: $0 22pd 01 40"
    exit 1
fi

# Assign input arguments to variables
prefix=$1
start=$2
end=$3

# Iterate over the specified range
for i in $(seq -w $start $end); do
    username="${prefix}${i}"
    email="${username}@psgtech.ac.in"

    # Execute the user creation command
    echo "Creating user: $username with email: $email"
    coder users create -u "$username" -e "$email" -p "$email"

    # Check if the command succeeded
    if [ $? -ne 0 ]; then
        echo "Failed to create user: $username"
    else
        echo "Successfully created user: $username"
    fi
done

echo "User creation process completed!"

