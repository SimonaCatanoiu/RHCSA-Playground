#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Create directory /webcontent/html/
mkdir -p /webcontent/html/
if [ $? -eq 0 ]; then
  success "Directory /webcontent/html/ created successfully."
else
  failure "Failed to create directory /webcontent/html/"
  exit 1
fi

# 2. Create file /webcontent/index.html
echo "Hello World!" > /webcontent/index.html
if [ $? -eq 0 ]; then
  success "File /webcontent/index.html created successfully."
else
  failure "Failed to create file /webcontent/index.html"
  exit 1
fi

# 3. Update httpd configuration
sed -i 's/^Listen .*/Listen 9787/' /etc/httpd/conf/httpd.conf
sed -i 's|^DocumentRoot ".*"|DocumentRoot "/webcontent"|' /etc/httpd/conf/httpd.conf
sed -i 's|^<Directory ".*">|<Directory "/webcontent">|' /etc/httpd/conf/httpd.conf

if [ $? -eq 0 ]; then
  success "httpd configuration updated successfully."
else
  failure "Failed to update httpd configuration."
  exit 1
fi

# Reload httpd service to apply changes (Optional)
# systemctl reload httpd

