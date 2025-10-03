#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Set root password to a random value
RAND_PASS=$(openssl rand -base64 12)
echo "root:${RAND_PASS}" | chpasswd
if [ $? -eq 0 ]; then
  success "Root password has been set to a random value."
else
  failure "Failed to set root password to a random value."
fi

# 2. Add entry to /etc/fstab to mount /dev/vde to /invalid
mkdir -p /invalid
echo "/dev/vde /invalid xfs defaults 0 0" >> /etc/fstab
if grep -q '/dev/vde' /etc/fstab ; then
  success "Entry for mounting /dev/vde to /invalid has been added to fstab."
else
  failure "Failed to add entry for mounting /dev/vde to /invalid in fstab."
fi
