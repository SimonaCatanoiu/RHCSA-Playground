#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check if /home/perms exists
if [ -d "/home/perms" ]; then
  success "Directory /home/perms exists."
else
  failure "Directory /home/perms does not exist."
  exit 1
fi

# Check user owner
if [ "$(stat -c '%U' /home/perms)" = "Andrew" ]; then
  success "User owner is set to Andrew."
else
  failure "User owner is not set to Andrew."
fi

# Check group owner
if [ "$(stat -c '%G' /home/perms)" = "admin" ]; then
  success "Group owner is set to admin."
else
  failure "Group owner is not set to admin."
fi

# Check sticky bit, setgid, and permissions
perms=$(stat -c '%a' /home/perms)
owner_perms=${perms:1:1}
group_perms=${perms:2:1}
other_perms=${perms:3:1}

# Check permissions
if [ "$owner_perms" -eq "7" ] && [ "$group_perms" -eq "7" ] && [ "$other_perms" -eq "1" ]; then
  success "Correct permissions are set."
else
  failure "Incorrect permissions are set."
fi

# Check sticky bit
if [[ $(stat -c '%A' /home/perms) == *t* ]]; then
  success "Sticky bit is set."
else
  failure "Sticky bit is not set."
fi

# Check setgid
if [[ $(stat -c '%A' /home/perms) == *s* ]]; then
  success "setgid is set."
else
  failure "setgid is not set."
fi
