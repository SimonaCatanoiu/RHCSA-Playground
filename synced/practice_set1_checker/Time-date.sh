#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Check if the timezone is set to Bucharest
if [[ $(timedatectl show --property=Timezone --value) == "Europe/Bucharest" ]]; then
  success "Timezone is set to Europe/Bucharest."
else
  failure "Timezone is not set to Europe/Bucharest."
fi

# 2. Check if NTP is set to true
if [[ $(timedatectl show --property=NTP --value) == "yes" ]]; then
  success "NTP is enabled."
else
  failure "NTP is not enabled."
fi

# 3. Check if there is an NTP server called ntp.server.com defined
# Note: This example assumes you are using chronyd for NTP, commonly used in Red Hat-based distributions.
if grep -q 'server ntp.server.com' /etc/chrony.conf; then
  success "NTP server ntp.server.com is defined in /etc/chrony.conf."
else
  failure "NTP server ntp.server.com is not defined in /etc/chrony.conf."
fi
