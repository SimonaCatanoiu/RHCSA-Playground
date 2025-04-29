#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check if the default target is set to multi-user.target
if [[ $(systemctl get-default) == "multi-user.target" ]]; then
  success "Default target is set to multi-user.target."
else
  failure "Default target is not set to multi-user.target. Current default target is $(systemctl get-default)."
fi
