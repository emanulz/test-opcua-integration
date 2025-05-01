# Local development instructions

For running this locally you need to install the following dependencies.

## Dependencies

- **Git**: get it from [HERE](https://git-scm.com/)
- **Node.js**: version 22.14.0 get it from [HERE](https://nodejs.org/es/download)
- **Yarn**: get it from [HERE](https://classic.yarnpkg.com/lang/en/docs/install/)

## Running the project

### Clone the repository

```bash
git clone https://github.com/emanulz/test-opcua-integration.git
```

### Install the dependencies

```bash
yarn install
```

### Set up the environment variables

Create a `.env` file in the root of the project and add the following variables and correct values:

```bash
# OPC server environment variables
OPC_ENDPOINT='opc.tcp://localhost:4840'
STATE_NODE_ID='ns=2;s=StateMachineNode'
ITEM_ID_NODE_ID='ns=2;s=ItemIdNode'
RESULT_NODE_ID='ns=2;s=ResultNode'
ERROR_NODE_ID='ns=2;s=ErrorNode'
START_STATE_VALUE='START'
DONE_STATE_VALUE='DONE'
NO_ERROR_CODE='0'
GENERAL_ERROR_CODE='9'
ITEM_NOT_FOUND_ERROR_CODE='1'

# API environment variables
API_BASE_URL='https://your-api-endpoint.com'
API_USER='yourUser'
API_PASSWORD='yourPassword'
API_WORKSPACE_ID='yourWorkspaceId'
API_USAGE_REASON=''
```

### Environment Variables Description

#### OPC Server Configuration

- `OPC_ENDPOINT`: The OPC UA server endpoint URL
- `STATE_NODE_ID`: Node ID for the state machine state
- `ITEM_ID_NODE_ID`: Node ID for reading the item ID
- `RESULT_NODE_ID`: Node ID for writing the API response
- `ERROR_NODE_ID`: Node ID for writing error codes
- `START_STATE_VALUE`: Value that triggers the process (default: 'START')
- `DONE_STATE_VALUE`: Value indicating process completion (default: 'DONE')
- `NO_ERROR_CODE`: Error code for no errors (default: 0)
- `GENERAL_ERROR_CODE`: Error code for general errors (default: 9)
- `ITEM_NOT_FOUND_ERROR_CODE`: Error code when no items are found (default: 1)

#### API Configuration

- `API_BASE_URL`: Base URL for the API
- `API_USER`: API username
- `API_PASSWORD`: API password
- `API_WORKSPACE_ID`: Workspace ID for API access
- `API_USAGE_REASON`: Reason for API usage

### Run the project for local development

```bash
yarn dev
```

## Error Handling

The system uses the following error codes:

- `NO_ERROR_CODE` (0): No errors, process completed successfully
- `ITEM_NOT_FOUND_ERROR_CODE` (1): No items found in the API response
- `GENERAL_ERROR_CODE` (9): Any other error occurred

The error code is written to the `ERROR_NODE_ID` node, and the state is always set to `DONE_STATE_VALUE` when the process completes, regardless of success or failure.

## Docker Instructions

This project can be run using Docker for easy deployment and consistent environment setup.

### Running Locally with Docker Compose

#### 1. Install Docker

Make sure Docker and Docker Compose are installed on your system:

- [Install Docker](https://docs.docker.com/get-docker/)

#### 2. Configure Environment Variables

You have two options for configuring environment variables:

##### Option A: Using a .env file (Recommended)

1. Create a `.env` file in the project root directory:

```bash
# Copy the example file
cp .env.example .env

# Edit the file with your actual values
nano .env
```

2. Your `.env` file should contain all necessary configuration:

```
# OPC UA Server
OPC_ENDPOINT=opc.tcp://your-opcua-server:4840
STATE_NODE_ID=ns=2;s=StateMachineNode
ITEM_ID_NODE_ID=ns=2;s=ItemIdNode
RESULT_NODE_ID=ns=2;s=ResultNode
ERROR_NODE_ID=ns=2;s=ErrorNode
START_STATE_VALUE=START
DONE_STATE_VALUE=DONE
NO_ERROR_CODE=0
GENERAL_ERROR_CODE=9
ITEM_NOT_FOUND_ERROR_CODE=1

# API Configuration
API_BASE_URL=https://your-api-endpoint.com
API_USER=yourUser
API_PASSWORD=yourPassword
API_WORKSPACE_ID=yourWorkspaceId
API_USAGE_REASON=integration
```

##### Option B: Direct in docker-compose.yml

Alternatively, you can edit the `docker-compose.yml` file and add environment variables directly:

```yaml
services:
  opcua-integration:
    # other config...
    environment:
      NODE_ENV: production
      OPC_ENDPOINT: opc.tcp://your-opcua-server:4840
      STATE_NODE_ID: ns=2;s=StateMachineNode
      ITEM_ID_NODE_ID: ns=2;s=ItemIdNode
      # Add all other required variables
```

#### 3. Create Required Directories

Create directories for persistent data storage:

```bash
mkdir -p data logs
```

#### 4. Build and Run with Docker Compose

Start the container:

```bash
docker-compose up -d --build
```

This command:

- Builds a Docker image for the application (`--build`)
- Starts the container in detached mode (`-d`)
- Sets up volume mapping for data persistence
- Configures environment variables

#### 5. Check Container Logs

View the application logs:

```bash
docker-compose logs -f
```

Press `Ctrl+C` to exit the log view.

#### 6. Stop the Container

When you're done:

```bash
docker-compose down
```

### Using the Helper Script

For convenience, a helper script is provided that handles directory creation and basic setup:

```bash
# Make the script executable
chmod +x scripts/docker-run.sh

# Run the script
./scripts/docker-run.sh
```

The script will:

1. Create necessary directories
2. Check for a `.env` file and create one from template if missing
3. Build and start the container

### Manual Docker Commands

If you prefer to run Docker commands directly:

```bash
# Build the Docker image
docker build -t opcua-integration .

# Run the container
docker run -d \
  --name opcua-integration \
  -v "$(pwd)/data:/app/data" \
  -v "$(pwd)/logs:/app/logs" \
  -v "$(pwd)/.env:/app/.env:ro" \
  opcua-integration

# View logs
docker logs -f opcua-integration

# Stop and remove container
docker stop opcua-integration
docker rm opcua-integration
```
