#!/bin/bash

# Helper functions for output
success() {
  echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
  echo -e "\e[31m$1 [FAILED]\e[0m"
}

# Check if group 'admin' has sudo privileges to execute all commands
admin_check=$(egrep -sir --exclude='*~' '^\s*%admin\s+ALL=\(ALL\)\s+ALL' /etc/sudoers /etc/sudoers.d/)
if [ -n "$admin_check" ]; then
  success "The group 'admin' has sudo privileges to execute all commands."
else
  failure "The group 'admin' does not have sudo privileges to execute all commands."
fi

# Check if user 'Dan' has sudo privileges to execute all commands
dan_check=$(egrep -sir --exclude='*~' '^\s*Dan\s+ALL=\(ALL\)\s+ALL' /etc/sudoers /etc/sudoers.d/)
if [ -n "$dan_check" ]; then
  success "The user 'Dan' has sudo privileges to execute all commands."
else
  failure "The user 'Dan' does not have sudo privileges to execute all commands."
fi

