#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check if the hostname is set to Mytesthost.com
if [[ $(hostname) == "Mytesthost.com" ]]; then
  success "Hostname is set to Mytesthost.com."
else
  failure "Hostname is not set to Mytesthost.com. Current hostname is $(hostname)."
fi
