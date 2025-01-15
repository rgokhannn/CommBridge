#!/bin/bash

# Exit if a command exits with a non-zero status
set -e

# Update the package index and upgrade installed packages to the latest versions
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Update the package index to get information on the newest versions of packages and their dependencies
echo "Updating the package index..."
sudo apt-get update

# Install ca-certificates and curl if they are not already installed
echo "Installing ca-certificates and curl..."
sudo apt-get install ca-certificates curl

# Create a directory for APT keyrings if it does not exist, with specific permissions
echo "Creating directory for APT keyrings, with specific permissions..."
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key and save it to the specified directory
echo "Downloading Docker's official GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Change the permissions of the Docker GPG key to be readable by all users
echo "Changing permissions of the Docker GPG key to be readable by all users..."
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker APT repository to your system's software repository list
# The repository is added with the architecture of the system and is signed by the downloaded GPG key
echo "Adding Docker APT repository to the system's software repository list..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index again to include the new Docker repository
echo "Updating the package index to include the new Docker repository..."
sudo apt-get update

# Install the Docker Compose plugin
echo "Installing Docker Compose plugin..."
sudo apt-get install docker-compose-plugin


echo "Docker and Docker Compose installation completed!"


# Install Python and pip
echo "Installing Python and pip..."
sudo apt install -y python3 python3-pip

echo "Setup Complete. Please verify Docker and Python installations."