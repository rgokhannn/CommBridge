#!/bin/bash

# Exit if a command exits with a non-zero status
set -e

# Define method in order to generate random credentials
generate_random() {
    openssl rand -base64 12
}

# Generate MongoDB credentials
MONGO_USER="mongo_user"
MONGO_PASS=$(generate_random)

# Generate RabbitMQ credentials
RABBITMQ_USER="rabbitmq_user"
RABBITMQ_PASS=$(generate_random)

# Generate Redis credentials
REDIS_PASS=$(generate_random)

# Write credentials to .env file
cat <<EOL > .env
MONGO_USER=${MONGO_USER}
MONGO_PASS=${MONGO_PASS}
RABBITMQ_USER=${RABBITMQ_USER}
RABBITMQ_PASS=${RABBITMQ_PASS}
REDIS_PASSWORD=${REDIS_PASS}
MONGODB_HOST=mongodb
RABBITMQ_HOST=rabbitmq
REDIS_HOST=redis
EOL

# Output the generated credentials
echo "Generated credentials and stored in .env:"
echo "MongoDB User: ${MONGO_USER}"
echo "MongoDB Pass: ${MONGO_PASS}"
echo "RabbitMQ User: ${RABBITMQ_USER}"
echo "RabbitMQ Pass: ${RABBITMQ_PASS}"
echo "Redis Password: ${REDIS_PASS}"