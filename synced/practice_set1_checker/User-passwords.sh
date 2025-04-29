#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check if users Pass1, Pass2, and Pass3 exist
for user in Pass1 Pass2 Pass3; do
  if id "$user" &>/dev/null; then
    success "User $user exists."
  else
    failure "User $user does not exist."
  fi
done

# Check if user Pass1's password expires every 10 days
if chage -l Pass1 | grep 'Maximum number of days between password change' | grep -q '10'; then
  success "Pass1's password expires every 10 days."
else
  failure "Pass1's password does not expire every 10 days."
fi

# Check if user Pass2's account expires in 30 days
current_date=$(date +%s)
expire_date=$(date -d "$(chage -l Pass2 | grep 'Account expires' | awk -F ': ' '{print $2}')" +%s)
days_to_expire=$(( (expire_date - current_date + 43200) / 86400 ))

if [ "$days_to_expire" -eq 30 ]; then
  success "Pass2's account expires in 30 days."
else
  failure "Pass2's account does not expire in 30 days. It expires in $days_to_expire days."
fi

# Check if user Pass3 needs to change password at next login
if chage -l Pass3 | grep 'Last password change' | grep -q 'password must be changed'; then
  success "Pass3 needs to change their password upon first login."
else
  failure "Pass3 does not need to change their password upon first login."
fi
