#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print messages
print_message() {
    echo -e "${GREEN}[DOCKER INSTALL]:${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]:${NC} $1"
}

# Function to check if a command was successful
check_status() {
    if [ $? -eq 0 ]; then
        print_message "$1"
    else
        print_error "$2"
        exit 1
    fi
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

# Uninstall old versions
print_message "Removing old Docker installations if they exist..."
apt-get remove -y docker docker-engine docker.io containerd runc >/dev/null 2>&1

# Update package index
print_message "Updating package index..."
apt-get update
check_status "Package index updated successfully" "Failed to update package index"

# Install prerequisites
print_message "Installing prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
check_status "Prerequisites installed successfully" "Failed to install prerequisites"

# Add Docker's official GPG key
print_message "Adding Docker's official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
check_status "Docker GPG key added successfully" "Failed to add Docker GPG key"

# Set up the repository
print_message "Setting up Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
check_status "Docker repository added successfully" "Failed to add Docker repository"

# Update package index again
print_message "Updating package index with Docker repository..."
apt-get update
check_status "Package index updated successfully" "Failed to update package index"

# Install Docker Engine
print_message "Installing Docker Engine..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_status "Docker Engine installed successfully" "Failed to install Docker Engine"

# Start and enable Docker service
print_message "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker
check_status "Docker service started and enabled successfully" "Failed to start Docker service"

# Add current user to docker group
if [ -n "$SUDO_USER" ]; then
    print_message "Adding user $SUDO_USER to docker group..."
    usermod -aG docker $SUDO_USER
    check_status "User added to docker group successfully" "Failed to add user to docker group"
fi

# Verify installation
print_message "Verifying Docker installation..."
docker --version
check_status "Docker installed and working correctly" "Docker installation verification failed"

print_message "Installation complete! Please log out and log back in for group changes to take effect."
print_message "You can verify the installation after logging back in by running: docker run hello-world" 