#!/bin/bash

# Exit if a command exits with a non-zero status
set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installating Git..."
sudo apt install -y git

echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl enable --now docker

echo "Installing Docker Compose..."
sudo apt-get install docker-compose-plugin

echo "Installing Python..."
sudo apt install -y python3 python3-pip

echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y openjdk-11-jre jenkins
sudo systemctl enable --now jenkins

echo "Setup Complete. Please verify Docker and Jenkins installations."

# Optional: Prompt to reboot
read -p "It's recommended to reboot the server now. Reboot? (y/n): " reboot_ans
if [[ "$reboot_ans" =~ ^[Yy]$ ]]; then
    sudo reboot
fi