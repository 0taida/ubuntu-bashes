#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

# Exit on any error
set -e

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Update package index
print_status "Updating package index..."
apt update
apt upgrade -y

# Install required dependencies
print_status "Installing required dependencies..."
apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

# Add Docker's official GPG key
print_status "Adding Docker's GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the Docker repository
print_status "Setting up Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index with Docker packages
print_status "Updating package index with Docker packages..."
apt update

# Install Docker Engine and related tools
print_status "Installing Docker Engine and related tools..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
print_status "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Install Docker Desktop
print_status "Installing Docker Desktop..."
DOCKER_DESKTOP_URL="https://desktop.docker.com/linux/main/amd64/docker-desktop-4.37.0-amd64.deb"
DOCKER_DESKTOP_DEB="docker-desktop.deb"

print_status "Downloading Docker Desktop..."
wget -O "$DOCKER_DESKTOP_DEB" "$DOCKER_DESKTOP_URL"

print_status "Installing Docker Desktop package..."
apt install -y "./$DOCKER_DESKTOP_DEB"
rm -f "$DOCKER_DESKTOP_DEB"

# Install Docker Compose v2
print_status "Installing Docker Compose v2..."
DOCKER_COMPOSE_VERSION="v2.20.0"
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify installation
print_status "Verifying installations..."
docker --version
docker compose version
docker-compose --version
print_status "Docker Desktop has been installed. You can launch it using 'docker-desktop' command"

print_status "Docker installation completed successfully!"

# Add current user to docker group to run docker without sudo
if [ -n "$SUDO_USER" ]; then
    print_status "Adding user $SUDO_USER to docker group..."
    usermod -aG docker $SUDO_USER
    print_status "Please log out and log back in for group changes to take effect."
fi

print_status "Installation complete! Please log out and log back in for group changes to take effect."
print_status "You can start Docker Desktop by running 'docker-desktop' or launching it from the Applications menu."
