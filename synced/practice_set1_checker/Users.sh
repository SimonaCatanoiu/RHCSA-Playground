#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Check if users Andrew, Dan, and Natalie exist
for user in Andrew Dan Natalie; do
  if id "$user" &>/dev/null; then
    success "User $user exists."
  else
    failure "User $user does not exist."
  fi
done

# 2. Check if the user Andrew has an UID of 1046
if [[ $(id -u Andrew 2>/dev/null) -eq 1046 ]]; then
  success "User Andrew has UID 1046."
else
  failure "User Andrew does not have UID 1046 or does not exist."
fi

# 3. Check if the group admin exists
if getent group admin >/dev/null; then
  success "Group admin exists."
else
  failure "Group admin does not exist."
fi
# 4. Check if the GID for group 'admin' is 10015
if getent group admin | grep -qE ':10015:'; then
  success "Group 'admin' has GID of 10015."
else
  failure "Group 'admin' does not have GID of 10015."
fi

# 5. Check if the users Andrew and Dan are part of the group admin
for user in Andrew Dan; do
  if groups "$user" 2>/dev/null | grep -q -w "admin"; then
    success "User $user is part of the group admin."
  else
    failure "User $user is not part of the group admin or does not exist."
  fi
done

# 6. Check if the user Natalie has a /sbin/nologin shell
if [[ $(getent passwd Natalie 2>/dev/null | cut -d: -f7) == "/sbin/nologin" ]]; then
  success "User Natalie has a /sbin/nologin shell."
else
  failure "User Natalie does not have a /sbin/nologin shell or does not exist."
fi

