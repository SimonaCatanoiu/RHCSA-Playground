#!/bin/bash

# Helper functions for output
success() {
  echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
  echo -e "\e[31m$1 [FAILED]\e[0m"
}


# 2. Check if /home/student/.config/systemd/user exists
if [ -d "/home/student/.config/systemd/user" ]; then
  success "Path /home/student/.config/systemd/user exists."
else
  failure "Path /home/student/.config/systemd/user does not exist."
fi

# 3. Check if container-webserver.service file exists
if [ -f "/home/student/.config/systemd/user/container-webserver.service" ]; then
  success "File container-webserver.service exists."
else
  failure "File container-webserver.service does not exist."
fi

# 4. Check if container-webserver is enabled under current user
if systemctl --user --quiet is-enabled container-webserver; then
  success "Service container-webserver is enabled."
else
  failure "Service container-webserver is not enabled."
fi

# 5. Check if enable-linger is enabled for user student
if loginctl show-user student | grep -q "Linger=yes"; then
  success "Enable-linger is enabled for user student."
else
  failure "Enable-linger is not enabled for user student."
fi

# 6. Check if systemctl --user start container-webserver creates a container called webserver
systemctl --user start container-webserver
sleep 3  # Give it a few seconds to initialize
if podman ps --format '{{.Names}}' | grep -q 'webserver'; then
  success "Systemctl --user start container-webserver created a container called webserver."
else
  failure "Systemctl --user start container-webserver did not create a container called webserver."
fi
