#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Check if there is a network connection called 'myconnection'
if nmcli con show | grep -q 'myconnection'; then
  success "Network connection 'myconnection' exists."
else
  failure "Network connection 'myconnection' does not exist."
  exit 1 # Exit the script as further checks would be meaningless
fi

# 2. Check if 'myconnection' is linked to 'eth0'
if nmcli -g connection.interface-name con show myconnection | grep -q 'eth0'; then
  success "'myconnection' is linked to 'eth0'."
else
  failure "'myconnection' is not linked to 'eth0'."
fi

# 3. Check for IP 192.168.1.1/24
# 4. Check for additional IP 192.168.1.2/24
ip_list=$(nmcli -g ipv4.addresses con show myconnection)
if echo "$ip_list" | grep -qE '192.168.1.1/24' && echo "$ip_list" | grep -qE '192.168.1.2/24'; then
  success "Both IPs 192.168.1.1/24 and 192.168.1.2/24 are set."
else
  failure "One or both of the IPs 192.168.1.1/24 and 192.168.1.2/24 are not set."
fi

# 5. Check for gateway 192.168.1.254
if nmcli -g ipv4.gateway con show myconnection | grep -q '192.168.1.254'; then
  success "Gateway is set to 192.168.1.254."
else
  failure "Gateway is not set to 192.168.1.254."
fi

# 6. Check for DNS 192.168.1.254
if nmcli -g ipv4.dns con show myconnection | grep -q '192.168.1.254'; then
  success "DNS is set to 192.168.1.254."
else
  failure "DNS is not set to 192.168.1.254."
fi

# 7. Check if connection is set to auto-start
if nmcli -g connection.autoconnect con show myconnection | grep -q 'yes'; then
  success "'myconnection' is configured to start automatically."
else
  failure "'myconnection' is not configured to start automatically."
fi
