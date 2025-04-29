#!/bin/bash

# Function for printing success and failure messages
success() {
  echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
  echo -e "\e[31m$1 [FAILED]\e[0m"
}

# Function to check /etc/login.defs settings
check_login_defs() {
  key="$1"
  expected_value="$2"
  description="$3"

  # Use regular expression to allow one or more spaces between the key and value
  actual_value=$(awk "/^$key[[:space:]]+${expected_value}\$/ { print \$2 }" /etc/login.defs)

  if [ "$actual_value" == "$expected_value" ]; then
    success "$description"
  else
    failure "$description"
  fi
}

# Check if PASS_MAX_DAYS is set to 30
check_login_defs "PASS_MAX_DAYS" "30" "Checking if default maximum password days is set to 30"

# Check if PASS_WARN_AGE is set to 5
check_login_defs "PASS_WARN_AGE" "5" "Checking if warn is set to 5"

# Check if PASS_MIN_DAYS is set to 10
check_login_defs "PASS_MIN_DAYS" "10" "Checking if pass_min_days is set to 10"


# Check if /etc/skel/All-users exists
if [ -f "/etc/skel/All-users" ]; then
  # Check if it contains the message "Created for all homes"
  if grep -q "Created for all homes" "/etc/skel/All-users"; then
    success "File /etc/skel/All-users exists and contains the message 'Created for all homes'."
  else
    failure "File /etc/skel/All-users exists but does not contain the message 'Created for all homes'."
  fi
else
  failure "File /etc/skel/All-users does not exist."
fi	