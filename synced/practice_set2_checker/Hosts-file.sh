#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check for the mapping 10.1.1.1 -> private in /etc/hosts
grep -w "10.1.1.1" /etc/hosts | awk '{for (i=2; i<=NF; i++) if ($i == "private") exit 0; exit 1}' &> /dev/null

if [ $? -eq 0 ]; then
  success "IP 10.1.1.1 is referenced with the name 'private' within the hosts file."
else
  failure "IP 10.1.1.1 is not referenced with the name 'private' within the hosts file."
fi
