#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+] $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[!] $1${NC}"
}

# Function to check if a command was successful
check_status() {
    if [ $? -eq 0 ]; then
        print_status "$1"
    else
        print_error "$2"
        exit 1
    fi
}

# Update package list
print_status "Updating package list..."
sudo apt update
check_status "Package list updated successfully" "Failed to update package list"

# Install dependencies
print_status "Installing dependencies..."
sudo apt install -y curl apt-transport-https
check_status "Dependencies installed successfully" "Failed to install dependencies"

# Install kubectl
print_status "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
check_status "kubectl downloaded successfully" "Failed to download kubectl"

chmod +x kubectl
check_status "kubectl permissions set successfully" "Failed to set kubectl permissions"

sudo mv kubectl /usr/local/bin/
check_status "kubectl moved to /usr/local/bin successfully" "Failed to move kubectl"

# Verify kubectl installation
kubectl version --client
check_status "kubectl installed successfully" "kubectl installation verification failed"

# Install Minikube
print_status "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
check_status "Minikube downloaded successfully" "Failed to download Minikube"

chmod +x minikube-linux-amd64
check_status "Minikube permissions set successfully" "Failed to set Minikube permissions"

sudo mv minikube-linux-amd64 /usr/local/bin/minikube
check_status "Minikube moved to /usr/local/bin successfully" "Failed to move Minikube"

# Verify Minikube installation
minikube version
check_status "Minikube installed successfully" "Minikube installation verification failed"

print_status "Installation completed successfully!"
print_status "You can now start Minikube using: minikube start"
