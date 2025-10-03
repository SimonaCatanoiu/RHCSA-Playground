#!/bin/bash

# Helper functions to display success or failure messages
success() {
    echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
    echo -e "\e[31m$1 [FAILED]\e[0m"
}

# Extract the UUID of the Stratis filesystem 'fs1' (assuming 'fs1' is on 'pool1')
uuid=$(stratis filesystem list | awk '/fs1/ {print $10}')

# Check if stratisd service is installed
if rpm -q stratisd &>/dev/null; then
    success "stratisd service is installed."
else
    failure "stratisd service is not installed."
fi

# Check if stratisd service is running
if systemctl is-active --quiet stratisd; then
    success "stratisd service is running."
else
    failure "stratisd service is not running."
fi

# Check if stratisd service is enabled
if systemctl is-enabled --quiet stratisd; then
    success "stratisd service is enabled."
else
    failure "stratisd service is not enabled."
fi

# Check if stratis pool called pool1 exists
if stratis pool list | grep -q 'pool1'; then
    success "Stratis pool 'pool1' exists."
else
    failure "Stratis pool 'pool1' does not exist."
fi

# Check if stratis filesystem called fs1 exists
if stratis filesystem list | grep -q 'fs1'; then
    success "Stratis filesystem 'fs1' exists."
else
    failure "Stratis filesystem 'fs1' does not exist."
fi

# Check if directory /mountstratis exists
if [ -d "/mountstratis" ]; then
    success "Directory /mountstratis exists."
else
    failure "Directory /mountstratis does not exist."
fi

# Check if stratis filesystem called fs1 is mounted on /mountstratis
if mount | grep -q '/mountstratis type xfs'; then
    success "Stratis filesystem 'fs1' is mounted on /mountstratis."
else
    failure "Stratis filesystem 'fs1' is not mounted on /mountstratis."
fi

# Check if stratis filesystem called fs1 is persistently mounted on /mountstratis in fstab using UUID and mount options
if grep -q "UUID=$uuid /mountstratis.*x-systemd.requires=stratisd.service" /etc/fstab; then
    success "Stratis filesystem 'fs1' is persistently mounted on /mountstratis in fstab with correct UUID and mount options."
else
    failure "Stratis filesystem 'fs1' is not persistently mounted on /mountstratis in fstab with correct UUID and mount options."
fi
