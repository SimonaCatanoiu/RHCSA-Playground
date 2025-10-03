#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check if firewalld default zone is set to public
firewalld_default_zone=$(firewall-cmd --get-default-zone)

if [ "$firewalld_default_zone" == "public" ]; then
  success "firewalld default zone is set to public."
else
  failure "firewalld default zone is NOT set to public. It is set to $firewalld_default_zone."
fi
