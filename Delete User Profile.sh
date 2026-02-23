#!/bin/bash

# Jamf passes the username from Parameter 4
TARGET_USER="$4"

# 1. Check if the parameter is empty
if [[ -z "$TARGET_USER" ]]; then
    echo "Error: No username specified in Parameter 4. Please check your Jamf Policy."
    exit 1
fi

# 2. Check if the user exists on this specific machine
if id "$TARGET_USER" &>/dev/null; then
    echo "User '$TARGET_USER' found. Proceeding with deletion..."
    
    # 3. Use sysadminctl to delete the user and their home folder securely
    # -deleteUser removes the record and the /Users/ folder
    sysadminctl -deleteUser "$TARGET_USER"
    
    # 4. Final verification
    if ! id "$TARGET_USER" &>/dev/null; then
        echo "Success: '$TARGET_USER' has been deleted."
        exit 0
    else
        echo "Error: Failed to delete '$TARGET_USER'."
        exit 1
    fi
else
    echo "User '$TARGET_USER' does not exist on this machine. Nothing to do."
    exit 0
fi