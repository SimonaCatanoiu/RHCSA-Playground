#!/bin/bash

# Check if the tuned service is enabled
systemctl is-enabled tuned &> /dev/null
if [[ $? -eq 0 ]]; then
    echo -e "\e[32mSuccess\e[0m: The tuned service is enabled."
else
    echo -e "\e[31mFailed\e[0m: The tuned service is not enabled."
fi

# Check if the tuned service is started
systemctl is-active tuned &> /dev/null
if [[ $? -eq 0 ]]; then
    echo -e "\e[32mSuccess\e[0m: The tuned service is started."
else
    echo -e "\e[31mFailed\e[0m: The tuned service is not started."
fi

# Check if the active profile is the recommended profile
active_profile=$(tuned-adm active | awk -F': ' '{print $2}')
recommended_by_tuned=$(tuned-adm recommend)
if [[ "$active_profile" == "$recommended_by_tuned" ]]; then
    echo -e "\e[32mSuccess\e[0m: The active profile is the recommended profile by tuned."
else
    echo -e "\e[31mFailed\e[0m: The active profile is not the recommended profile by tuned. Active: $active_profile, Recommended: $recommended_by_tuned."
fi
