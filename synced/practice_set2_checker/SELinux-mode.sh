#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Check if SELinux is currently set to permissive mode
current_mode=$(getenforce)
if [[ $current_mode == "Permissive" ]]; then
  success "SELinux is currently set to Permissive mode."
else
  failure "SELinux is not currently set to Permissive mode."
fi

# 2. Check if SELinux is configured to start in permissive mode upon boot
configured_mode=$(awk -F= '/^SELINUX=/ {print $2}' /etc/selinux/config)
if [[ $configured_mode == "permissive" ]]; then
  success "SELinux is configured to start in Permissive mode upon boot."
else
  failure "SELinux is not configured to start in Permissive mode upon boot."
fi
