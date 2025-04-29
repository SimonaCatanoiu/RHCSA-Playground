#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check SELinux context of /webcontent directory
dir_context=$(ls -Zd /webcontent | awk '{print $1}' | awk -F: '{print $3}')
if [[ "$dir_context" == "httpd_sys_content_t" ]]; then
  echo -e "\e[32mSuccess: /webcontent has the correct SELinux context.\e[0m"
else
  echo -e "\e[31mFailed: /webcontent does not have the correct SELinux context.\e[0m"
  all_good=false
fi

# Check SELinux context of files within /webcontent
for file in /webcontent/*; do
  file_context=$(ls -Z $file | awk '{print $1}' | awk -F: '{print $3}')
  if [[ "$file_context" == "httpd_sys_content_t" ]]; then
    echo -e "\e[32mSuccess: $file has the correct SELinux context.\e[0m"
  else
    echo -e "\e[31mFailed: $file does not have the correct SELinux context.\e[0m"
    all_good=false
  fi
done

# 2. Check if SELinux allows HTTP on port 9787
port_status=$(semanage port -l | grep 'http_port_t' | grep '9787')
if [ -n "$port_status" ]; then
  success "SELinux permits HTTP on port 9787."
else
  failure "SELinux does NOT permit HTTP on port 9787."
fi

# 3. Check if firewalld allows HTTP service
firewalld_http_status=$(firewall-cmd --list-services | grep 'http')
if [ -n "$firewalld_http_status" ]; then
  success "firewalld allows HTTP service."
else
  failure "firewalld does NOT allow HTTP service."
fi

# 4. Check if firewalld allows traffic on 9787/tcp
firewalld_9787_status=$(firewall-cmd --list-ports | grep '9787/tcp')
if [ -n "$firewalld_9787_status" ]; then
  success "firewalld permits traffic on 9787/tcp."
else
  failure "firewalld does NOT permit traffic on 9787/tcp."
fi

# 5. Check if curl to localhost:9787/index.html returns "Hello World!"
curl_output=$(curl -s localhost:9787/index.html)
if [ "$curl_output" == "Hello World!" ]; then
  success "curl command on localhost:9787/index.html returns 'Hello World!'."
else
  failure "curl command on localhost:9787/index.html does NOT return 'Hello World!'."
fi
