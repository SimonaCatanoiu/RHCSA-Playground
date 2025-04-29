#!/bin/bash

# Helper functions to display success or failure messages
success() {
    echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
    echo -e "\e[31m$1 [FAILED]\e[0m"
}

# Check if the Podman container 'webserver' is running
if podman ps --format '{{.Names}}' | grep -q 'webserver'; then
    success "Container 'webserver' is running."
else
    failure "Container 'webserver' is not running."
fi

# Check if the container 'webserver' forwards port 8080
if podman port webserver | grep -q '8080/tcp -> 0.0.0.0:8080'; then
    success "Container 'webserver' forwards port 8080."
else
    failure "Container 'webserver' does not forward port 8080."
fi

# Check if directory /containercontent exists
if [ -d "/home/student/containercontent" ]; then
    success "Directory /home/student/containercontent exists."
else
    failure "Directory /home/student/containercontent does not exist."
fi

# Check if index.html exists and contains "Hello Container!"
if grep -q 'Hello Container!' /home/student/containercontent/index.html; then
    success "File index.html contains 'Hello Container!'."
else
    failure "File index.html does not contain 'Hello Container!'."
fi

# Check if directory is mounted within the container
if podman inspect webserver --format '{{.Mounts}}' | grep -q '/home/student/containercontent /var/www/html'; then
    success "Directory is mounted within the container."
else
    failure "Directory is not mounted within the container."
fi

# Check if curl command returns "Hello Container"
if curl -s http://localhost:8080/ | grep -q 'Hello Container'; then
    success "Curl command returns 'Hello Container'."
else
    failure "Curl command does not return 'Hello Container'."
fi

# Check if firewalld allows traffic on port 8080
if sudo firewall-cmd --list-ports | grep -q '8080/tcp'; then
    success "Firewalld allows traffic on port 8080."
else
    failure "Firewalld does not allow traffic on port 8080."
fi
