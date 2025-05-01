#!/bin/bash
set -e

echo "=== Environment File Debugging ==="

# Check if .env exists in current directory
echo "1. Checking for .env file in current directory..."
if [ -f ".env" ]; then
  echo "✅ .env file found in the current directory"
  echo "   File size: $(stat -c%s ".env") bytes"
  echo "   Last modified: $(stat -c%y ".env")"
  echo "   First few lines (sensitive data redacted):"
  head -n 3 .env | sed 's/=.*/=****/'
else
  echo "❌ .env file NOT found in current directory!"
  echo "   Creating a sample .env file..."
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "   Created .env from .env.example template"
  else
    echo "# Sample environment file - PLEASE EDIT WITH REAL VALUES" > .env
    echo "OPC_ENDPOINT=opc.tcp://your-ip:4840/UA/TestServer" >> .env
    echo "STATE_NODE_ID=ns=2;s=StateMachineNode" >> .env
    echo "ITEM_ID_NODE_ID=ns=2;s=ItemIdNode" >> .env
    echo "   Created basic .env file - please edit with real values"
  fi
fi

# Ensure directories exist
echo "2. Ensuring data and logs directories exist..."
mkdir -p data logs
echo "✅ Created data and logs directories"

# Check Docker configuration
echo "3. Checking Docker container status..."
if docker ps | grep -q opcua-integration; then
  echo "✅ Container is running, checking for mounted .env file..."
  docker exec opcua-integration sh -c '
    if [ -f "/app/.env" ]; then
      echo "✅ .env file found in container at /app/.env"
      echo "   File size: $(stat -c%s "/app/.env") bytes"
      ls -la /app/.env
    else
      echo "❌ .env file NOT found in container!"
      echo "   Contents of /app directory:"
      ls -la /app/
    fi
  ' || echo "❌ Failed to execute command in container"
else
  echo "❌ Container is not running"
  echo "   Checking docker-compose.yml volumes configuration..."
  if grep -q "./.env:/app/.env" docker-compose.yml; then
    echo "✅ Volume mount for .env found in docker-compose.yml"
  else
    echo "❌ Volume mount for .env NOT found in docker-compose.yml!"
  fi
fi

# Provide solutions
echo ""
echo "=== Potential Solutions ==="
echo "1. Ensure .env file exists in project root directory (same as docker-compose.yml)"
echo "2. Make sure the volume mount in docker-compose.yml is correct:"
echo "   - ./.env:/app/.env:ro"
echo "3. Try copying the .env file into the image by uncommenting this line in Dockerfile:"
echo "   COPY .env ./"
echo "4. Rebuild and restart:"
echo "   docker-compose down"
echo "   docker-compose up -d --build"
echo ""
echo "5. For a quick test, try setting environment variables directly in docker-compose.yml:"
echo "   environment:"
echo "     NODE_ENV: production"
echo "     OPC_ENDPOINT: opc.tcp://your-ip:4840/UA/TestServer"
echo "     STATE_NODE_ID: ns=2;s=StateMachineNode"
echo "     # Add other variables as needed" 
