
# CommBridge

Commbridge is an API application that integrates with various technologies like RabbitMQ, Redis, and MongoDB to facilitate data transmission, caching, and persistent data storage. This application provides an efficient way to manage data flow and message delivery.
## Features

- Send and receive messages using RabbitMQ.
- Cache messages using Redis.
- Persistently store messages using MongoDB.
  
## Requirements

- Jenkins 
- Network:
  - Ensure ports `2376`, `5000`, `5672`,  `8080`, `15672`, `6379`, and `27017` are open.
- Docker (Will be installed via Jenkinsfile)
- Docker Compose (Will be installed via Jenkinsfile)
- Python 3.9+ (Will be installed via Jenkinsfile)
- Operating System: Tested primarily on **Ubuntu 24.04 LTS**.

## Initial Setup

1. **Clone the Repository:**

   First, clone the CommBridge repository to your local server.

   ```bash
   git clone https://github.com/rgokhannn/CommBridge.git
   ```

2. **Navigate to the Cloned Directory:**

   Access the contents of the cloned directory.

   ```bash
   cd CommBridge
   ```

3. **Make the Script Executable:**

   Ensure the `installJenkins.sh` script is executable, and if necessary, make it executable.

   ```bash
   chmod +x installJenkins.sh
   ```

4. **Run the Installation Script:**

   Execute the script to complete the Jenkins installation.

   ```bash
   ./installJenkins.sh
   ```
5. **Setup Jenkins Job:**

    Create a Jenkins pipeline job using the provided Jenkinsfile in the repository and set the repository URL.
    The Jenkinsfile in the repository will automatically:
    - Install Docker, Docker Compose, and Python via initialSetup.sh script.
    - Generates and outputs the credentials to be used by Redis, RabbitMQ and MongoDB applications to .env file via generateCredentials.sh script.
    - Build Docker images for the application.
    - Start RabbitMQ, Redis, MongoDB and Application using Docker Compose.

## Usage

The application provides the following API endpoint(s):

1. **Send Message:**

   - Endpoint: `/send`
   - Method: `POST`
   - Sample Request:

     ```bash
     curl -X POST -H "Content-Type: application/json" -d '{"message": "Your Message"}' http://localhost:5000/produce
     ```

   - Description: Sends the specified message to RabbitMQ and caches it in Redis.