#!/bin/bash

# Install Jenkins

# Check if script is run as root
# For security reasons, the script requires root privileges to execute. If not run as root, it will exit with a message.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo."
    exit 1
fi

echo "Starting Jenkins installation..."

# Update and upgrade the system packages
# It's a good practice to ensure the system is up-to-date before installing new software.
sudo apt update -y
sudo apt upgrade -y

echo "Installing JDK 17..."
# Install OpenJDK 17
# Jenkins requires Java to function. This installs the JDK 17 version which is recommended.
sudo apt install openjdk-17-jdk -y

# Import Jenkins GPG key
# This step adds a secure key to verify the authenticity of Jenkins packages.
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository..."
# Add the Jenkins package repository to the system
# This allows us to install Jenkins using the apt package manager.
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating package list..."
# Update the package list again to include Jenkins packages
# This refreshes the list of available packages and their versions.
sudo apt update -y

echo "Installing Jenkins..."
# Install Jenkins
# Download and install Jenkins using the package manager.
sudo apt install jenkins -y

echo "Starting Jenkins and enabling service..."
# Start Jenkins and enable it to start on boot
# This starts the Jenkins service immediately and ensures it starts on system reboot.
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check if Jenkins service is active
# This ensures that Jenkins started successfully; if not, it prompts the user to check logs.
if systemctl is-active --quiet jenkins; then
    echo "Jenkins started successfully, script will continue with configuration."
else
    echo "Jenkins failed to start. Exiting. Please check the logs for more information."
    echo "Logs are located in /var/log/jenkins/jenkins.log"
    exit 1
fi

# Jenkins user and sudoers file variables to configure sudo access
JENKINS_USER="jenkins"
SUDOERS_FILE="/etc/sudoers.d/jenkins"

# Commands allowed to the Jenkins user without password using sudo
# These are the commands Jenkins can execute without needing a password.
ALLOWED_COMMANDS="/usr/local/bin/kubectl, /usr/local/bin/helm, /usr/bin/docker, /bin/chmod, /bin/chown, /usr/bin/terraform, /usr/local/bin/kind"

echo "Configuring sudoers for Jenkins user..."

# Create or overwrite the sudoers file for Jenkins
# This configuration allows specified commands to be run by Jenkins user without sudo password.
sudo cat <<EOF > $SUDOERS_FILE
$JENKINS_USER ALL=(ALL) NOPASSWD: $ALLOWED_COMMANDS
EOF

# Set correct permissions on the sudoers file
# It's crucial to set the correct permissions to prevent unauthorized alterations.
sudo chmod 440 $SUDOERS_FILE

# Validating the sudoers configuration
# Use visudo to verify there are no syntax errors in the sudoers file.
if visudo -cf $SUDOERS_FILE; then
    echo "Sudoers file updated successfully for Jenkins user."
else
    echo "Error in sudoers configuration. Rolling back changes."
    rm -f $SUDOERS_FILE
    exit 1
fi

# Inform the user about the commands Jenkins can execute
echo "Jenkins user can now execute the following commands without sudo:"
echo "$ALLOWED_COMMANDS"

# Restart Jenkins to apply new settings
# Restart the service to ensure all configuration changes are applied.
echo "Restarting Jenkins service..."
sudo systemctl restart jenkins

# Check if Jenkins restarted successfully
# Verifies the service is active post-restart, ensuring no configuration errors were introduced.
if systemctl is-active --quiet jenkins; then
    echo "Jenkins restarted successfully."
else
    echo "Jenkins failed to restart. Exiting. Please check the logs for more information."
    echo "Logs are located in /var/log/jenkins/jenkins.log"
    exit 1
fi

echo "Configuration completed!"

# Provide the user with the initial admin password location
# Outputs instructions on how to access Jenkins for the first time.
echo "Jenkins installation completed with JDK 17. To retrieve the initial admin password, run the following command:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "To complete setup, open http://localhost:8080 in your web browser."