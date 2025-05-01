#!/bin/bash
set -e

# Create required directories
mkdir -p data logs

# Check if .env file exists
if [ ! -f ".env" ]; then
  echo "Creating .env file template..."
  cp .env.example .env
  echo "Please edit the .env file with your actual configuration values before running the container."
  exit 1
fi

# Build and run the container
echo "Building and starting the container..."
docker-compose up -d --build

echo "Container is running. Check logs with:"
echo "docker-compose logs -f"
echo
echo "To stop the container:"
echo "docker-compose down" 
