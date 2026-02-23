Technical Breakdown of the Script

1. Parameter Handling ($4)

In Jamf Pro, parameters 1 through 3 are reserved by the binary (Mount Point, Computer Name, and Username of the current user). By using Parameter 4, we allow the Jamf admin to pass a custom string—the target username—into the script environment without hardcoding it.

2. Identity Validation

The script uses the id command:

id "$TARGET_USER": This queries the Open Directory (the local database of users and groups).

&>/dev/null: This redirects both Standard Output and Standard Error to "nowhere." We don't need to see the user's UID or GID; we only care about the exit code.

Exit Code 0: User exists.

Exit Code 1+: User does not exist.

3. Execution via sysadminctl

The command sysadminctl -deleteUser "$TARGET_USER" is the modern Apple standard for account management. Unlike older methods (like dscl . -delete /Users/username), sysadminctl performs several background tasks automatically:

Directory Node Removal: Deletes the user record from /Local/Default.

Home Directory Cleanup: Safely deletes the contents of /Users/[username].

Secure Token Revocation: If the user has a Secure Token (used for FileVault), this command ensures the token is invalidated and the disk's crypto-user list is updated.

4. Post-Execution Verification

The script runs the id command a second time. This is a "fail-safe" step. If id still finds the user after the deletion command was issued, the script exits with an error code (exit 1), which flags the policy as Failed in your Jamf Pro dashboard, alerting you that manual intervention is needed.

Logic Flow Diagram

Component	Technical Function
Interpreter	#!/bin/bash - Tells the OS to use the Bourne Again Shell.
Logic Gate	if [[ -z "$TARGET_USER" ]] - Prevents the script from running with a "null" name, which could be dangerous.
Binary Used	/usr/sbin/sysadminctl - The primary system administration tool for macOS.
Exit Status	Returns 0 for success or 1 for failure to Jamf Pro for reporting.
