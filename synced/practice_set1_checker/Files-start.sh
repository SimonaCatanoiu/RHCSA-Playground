#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check for root user
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# 1. Create the user 'William'
useradd William &> /dev/null
if getent passwd William &> /dev/null; then
  success "User 'William' was created successfully."
else
  failure "Failed to create user 'William'."
fi

# 2. Create a file /var/log/Findme belonging to William
touch /var/log/Findme && chown William /var/log/Findme
if [ $? -eq 0 ]; then
  success "First File belonging to William was created successfully."
else
  failure "Failed to create /var/log/Findme belonging to William."
fi

# 3. Create a file /tmp/Findme2 belonging to William
touch /tmp/Findme2 && chown William /tmp/Findme2
if [ $? -eq 0 ]; then
  success "Second File belonging to William was created successfully."
else
  failure "Failed to create /tmp/Findme2 belonging to William."
fi

# 4. Create a folder /home/Archiveme containing 3 empty files
mkdir /home/Archiveme && touch /home/Archiveme/file1 /home/Archiveme/file2 /home/Archiveme/file3
if [ $? -eq 0 ]; then
  success "Folder /home/Archiveme with 3 empty files was created successfully."
else
  failure "Failed to create folder /home/Archiveme with 3 empty files."
fi

# 5. Create a file /home/Linkme
echo Please Link Me > /home/Linkme
if [ $? -eq 0 ]; then
  success "File /home/Linkme was created successfully."
else
  failure "Failed to create /home/Linkme."
fi
