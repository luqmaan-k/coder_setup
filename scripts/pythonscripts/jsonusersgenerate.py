#!/usr/bin/env python3
"""
Script: generate_users_json.py
Description:
  Generates a JSON file of users based on a username prefix and numeric range.
  It calculates the proper zero-padding based on the maximum length of the lower and upper bounds.
  For each user, a secure password of exactly 12 characters is generated.
  Passwords are guaranteed to include at least one uppercase letter, one lowercase letter, one digit, and one special character.
  
Usage:
  python generate_users_json.py <prefix> <lower_bound> <upper_bound> <output_json_file>
Example:
  python generate_users_json.py user 001 199 users.json

Note:
  The generated passwords are 12 characters long. You may adjust the character pools if needed.
"""

import sys
import json
import os
import string
import secrets

# Secure password generation parameters
PASSWORD_LENGTH = 12

# Define the character groups
LOWERCASE = string.ascii_lowercase
UPPERCASE = string.ascii_uppercase
DIGITS = string.digits
SPECIAL = "!@#$%^&*()-_=+[]{};:,.<>?/"

# Combined pool: you can adjust this as necessary (exclude ambiguous characters if desired)
ALL_CHARS = LOWERCASE + UPPERCASE + DIGITS + SPECIAL

def generate_secure_password(length=PASSWORD_LENGTH):
    """Generate a secure password of a fixed length that includes at least one lowercase, one uppercase, one digit, and one special character."""
    if length < 4:
        raise ValueError("Password length must be at least 4 to satisfy all character type requirements.")

    # Ensure each required category is represented:
    password_chars = [
        secrets.choice(LOWERCASE),
        secrets.choice(UPPERCASE),
        secrets.choice(DIGITS),
        secrets.choice(SPECIAL)
    ]
    
    # Fill the remaining length with randomly chosen characters from all groups.
    remaining = length - 4
    password_chars.extend(secrets.choice(ALL_CHARS) for _ in range(remaining))
    
    # Shuffle the list so the fixed characters aren't always in the same order.
    secrets.SystemRandom().shuffle(password_chars)
    
    # Join into a string and return.
    return ''.join(password_chars)

def main(args):
    if len(args) != 5:
        print(f"Usage: {args[0]} <prefix> <lower_bound> <upper_bound> <output_json_file>")
        sys.exit(1)

    _, prefix, lower_bound, upper_bound, output_file = args

    # Determine the proper zero-padding width from the lower and upper bounds.
    width_lower = len(lower_bound)
    width_upper = len(upper_bound)
    if width_upper > width_lower:
        width = width_upper
    else:
        width = width_lower

    # Convert the lower and upper bounds to integers (ignoring leading zeros)
    try:
        start = int(lower_bound)
        end = int(upper_bound)
    except ValueError:
        print("Error: lower_bound and upper_bound must be valid integers (even if padded).")
        sys.exit(1)

    # Generate the list of users.
    users = []
    for i in range(start, end + 1):
        # Create username using the proper zero-padding.
        username = f"{prefix}{i:0{width}d}"
        # Construct the email address (adjust the domain if needed)
        email = f"{username}@psgtech.ac.in"
        # Generate a secure random password.
        password = generate_secure_password(PASSWORD_LENGTH)
        users.append({
            "username": username,
            "email": email,
            "password": password
        })

    # Write the users list to the output JSON file.
    try:
        with open(output_file, 'w') as f:
            json.dump(users, f, indent=4)
        print(f"User list with secure passwords has been written to '{output_file}'.")
    except Exception as e:
        print(f"Error writing to JSON file: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main(sys.argv)

