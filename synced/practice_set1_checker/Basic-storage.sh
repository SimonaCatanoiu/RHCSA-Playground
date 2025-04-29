#!/bin/bash

# Function to print messages in green for success or red for failure
print_message() {
    if [ "$1" == "success" ]; then
        echo -e "\e[32mSuccess\e[0m"
    else
        echo -e "\e[31mFailed\e[0m"
    fi
}

# Initialize a counter for partitions within the size range
count=0

# Use lsblk to list the partitions and awk to filter out those with sizes between 600M and 680M
count=$(lsblk -o SIZE,TYPE | awk '/part/ {gsub(/M/,""); if ($1 >= 600 && $1 <= 680) count++} END {print count}')

# Check if there are exactly 2 partitions in the specified size range
if [ "$count" -eq "2" ]; then
    print_message "Success: There are 2 partitions with a size between 600-650M"
else
    print_message "Failed: There aren't 2 partitions with a size between 600-650M"
fi







