#!/bin/bash

# Helper functions for output
success() {
  echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
  echo -e "\e[31m$1 [FAILED]\e[0m"
}

# Full path to the repo file
repo_file="/etc/yum.repos.d/BaseOS.repo"

# Check if the BaseOS.repo file exists in yum.repos.d
if [ -f "$repo_file" ]; then
  success "BaseOS.repo exists within yum.repos.d"
else
  failure "BaseOS.repo does not exist within yum.repos.d"
  exit 1
fi

# Check if the URL within that repo file is set to http://myrepo.com
if grep -E "^baseurl=http://myrepo.com" "$repo_file" > /dev/null 2>&1; then
  success "URL within repo file is set to http://myrepo.com"
else
  failure "URL within repo file is not set to http://myrepo.com"
  exit 1
fi

# Check if the repo is enabled
if grep -E "^enabled=(1|true)" "$repo_file" > /dev/null 2>&1; then
  success "BaseOS.repo is enabled"
else
  failure "BaseOS.repo is not enabled"
  exit 1
fi

# Check if the repo name is BaseOS.Dvd
if grep -E "^name=BaseOS" "$repo_file" > /dev/null 2>&1; then
  success "Name is BaseOS"
else
  failure "Name is BaseOS"
  exit 1
fi

# Check if the id is "BaseOS.Dvd"
if grep -E "^\[BaseOS\.Dvd\]" "$repo_file" > /dev/null 2>&1; then
  success "ID is set to BaseOS.Dvd"
else
  failure "ID is not set to BaseOS.Dvd"
  exit 1
fi

