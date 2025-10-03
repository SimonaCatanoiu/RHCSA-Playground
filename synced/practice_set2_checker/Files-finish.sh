#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# 1. Check if the absolute paths of files 'Findme' and 'Findme2' are in the text file '/home/Paths'
if grep -Fxq "$(readlink -f /var/log/Findme)" /home/Paths && grep -Fxq "$(readlink -f /tmp/Findme2)" /home/Paths; then
  success "Absolute paths of 'Findme' and 'Findme2' are present in '/home/Paths'."
else
  failure "Absolute paths of 'Findme' and/or 'Findme2' are not present in '/home/Paths'."
fi

# 2. Check if there is a symbolic link '/home/Softlink' pointing to '/home/Linkme'
if [ -L "/home/Softlink" ] && [ "$(readlink -f /home/Softlink)" == "/home/Linkme" ]; then
  success "Symbolic link '/home/Softlink' pointing to '/home/Linkme' exists."
else
  failure "Symbolic link '/home/Softlink' pointing to '/home/Linkme' does not exist."
fi

# 3. Check if there is a hard link '/home/Hardlink' pointing to '/home/Linkme'
if [ -f "/home/Hardlink" ] && [ "$(stat -c %i /home/Hardlink)" == "$(stat -c %i /home/Linkme)" ]; then
  success "Hard link '/home/Hardlink' pointing to '/home/Linkme' exists."
else
  failure "Hard link '/home/Hardlink' pointing to '/home/Linkme' does not exist."
fi

# 4. Check if there is an archive '/home/Archiveme.tar.gz' with gzip compression containing the contents of '/home/Archiveme'
if [ -f "/home/Archiveme.tar.gz" ]; then
  tar -tzf /home/Archiveme.tar.gz &> /dev/null
  if [ $? -eq 0 ]; then
    if tar -tzf /home/Archiveme.tar.gz | grep -q -E "^Archiveme/"; then
      success "Archive '/home/Archiveme.tar.gz' with gzip compression containing the contents of '/home/Archiveme' exists."
    else
      failure "Archive '/home/Archiveme.tar.gz' does not contain the contents of '/home/Archiveme'."
    fi
  else
    failure "File '/home/Archiveme.tar.gz' is not a valid gzip compressed archive."
  fi
else
  failure "Archive '/home/Archiveme.tar.gz' does not exist."
fi
