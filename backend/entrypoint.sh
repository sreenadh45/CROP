#!/bin/bash

echo "Starting Crop Marketplace Application..."

# Wait for database
echo "Waiting for database..."
while ! nc -z ${DB_HOST} ${DB_PORT}; do
  sleep 1
done
echo "Database is ready!"

# Wait for Redis
echo "Waiting for Redis..."
while ! nc -z ${REDIS_HOST} ${REDIS_PORT}; do
  sleep 1
done
echo "Redis is ready!"

# Wait for RabbitMQ
echo "Waiting for RabbitMQ..."
while ! nc -z ${RABBITMQ_HOST} ${RABBITMQ_PORT}; do
  sleep 1
done
echo "RabbitMQ is ready!"

# Run database migrations
echo "Running database migrations..."
java -jar app.jar db:migrate

# Start application
echo "Starting Spring Boot application..."
exec java $JAVA_OPTS -jar app.jar
