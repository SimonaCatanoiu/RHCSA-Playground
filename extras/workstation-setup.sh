#!/bin/bash

# Create symbolic link for synced folder
export SYNCED=/home/student/synced
if [ ! -L $SYNCED ]; then
  ln -s /synced /home/student
  echo "→→→ Symbolic link created ~~"
else
  echo "→→→ Nothing to do here ~~"
fi

# Install Gnome
dnf groupinstall -y "Server with GUI"
systemctl set-default graphical
systemctl isolate graphical.target

# Copy Validation Scripts
# Define variables
SRC="/synced"
DEST="/home/student/practice_set1_checker"
LINK="/home/student/synced"

# Ensure destination exists and copy
echo "→ Copying synced folder to student's practice_set1_checker..."
cp -R "$SRC" "$DEST"
echo "✓ Copied to $DEST"

# Make all files inside destination executable
echo "→ Making all files in $DEST executable..."
find "$DEST" -type f -exec chmod +x {} \;
echo "✓ Permissions updated"