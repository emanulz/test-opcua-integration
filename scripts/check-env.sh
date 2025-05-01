#!/bin/bash
set -e

# Check if container is running
if ! docker ps | grep -q opcua-integration; then
  echo "Container 'opcua-integration' is not running. Starting it..."
  docker-compose up -d
fi

echo "Checking environment variables inside the container..."
docker exec opcua-integration /bin/sh -c "
  echo 'Node.js environment variables:'
  node -e '
    console.log(\"OPC_ENDPOINT = \" + process.env.OPC_ENDPOINT);
    console.log(\"STATE_NODE_ID = \" + process.env.STATE_NODE_ID);
    console.log(\"API_BASE_URL = \" + process.env.API_BASE_URL);
  '

  echo '\nEnvironment variables in .env file:'
  if [ -f /app/.env ]; then
    cat /app/.env | grep -v PASSWORD | grep -v SECRET
  else
    echo '.env file not found in /app/'
  fi

  echo '\nChecking file permissions:'
  ls -la /app/ | grep .env
"

echo -e "\nTroubleshooting Tips:"
echo "1. Make sure your .env file exists in the project root"
echo "2. Verify that docker-compose.yml has the correct volume mount:"
echo "   - ./.env:/app/.env:ro"
echo "3. Check for any syntax errors in your .env file"
echo "4. Try rebuilding the image with docker-compose up -d --build" 
