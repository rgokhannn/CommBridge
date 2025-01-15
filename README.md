
# CommBridge

Commbridge is an API application that integrates with various technologies like RabbitMQ, Redis, and MongoDB to facilitate data transmission, caching, and persistent data storage. This application provides an efficient way to manage data flow and message delivery.
## Features

- Send and receive messages using RabbitMQ.
- Cache messages using Redis.
- Persistently store messages using MongoDB.
  
## Requirements

- Jenkins: For CI/CD pipelines.
  - Jenkins Plugins
    - Docker Plugin: For building and managing Docker containers.
    - Git Plugin: For integrating with Git repositories.
    - Pipeline Plugin: For defining and running jobs using Jenkins pipelines.
- Network:
  - Ensure ports `2376`, `5000`, `5672`, `15672`, `6379`, and `27017` are open.
- Docker (Will be installed via Jenkinsfile)
- Docker Compose (Will be installed via Jenkinsfile)
- Python 3.9+ (Will be installed via Jenkinsfile)
- Operating System: Tested primarily on **Ubuntu 24.04 LTS**.

## Initial Setup

1. **Clone the Repository:**

   First, clone the repository to your server:

   ```bash
   git clone https://github.com/rgokhannn/messagebridge.git
   ```
2. **Setup Jenkins Job:**

    Create a Jenkins pipeline job using the provided Jenkinsfile in the repository and set the repository URL.
    The Jenkinsfile in the repository will automatically:
    - Update and install necessary packages.
    - Install Docker and Docker Compose.
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