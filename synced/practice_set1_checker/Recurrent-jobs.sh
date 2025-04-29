#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Check if there's a system cron job running a script in /home/myscript.sh every Tuesday at 5 PM
if sudo grep -qE '0 17 \* \* 2 root /home/myscript.sh' /etc/cron.d/sysjob; then
  success "System cron job found for running /home/myscript.sh every Tuesday at 5 PM."
else
  failure "System cron job not found for running /home/myscript.sh every Tuesday at 5 PM."
fi

# 2. Check if there is a cron job running under the user Andrew running the echo test command every hour at minute 10 everyday in January
if sudo crontab -l -u Andrew 2>/dev/null | grep -qE '10 \* \* 1 \* echo test'; then
  success "User cron job found for Andrew, running 'echo test' every hour at minute 10 every day in January."
else
  failure "User cron job not found for Andrew, running 'echo test' every hour at minute 10 every day in January."
fi
