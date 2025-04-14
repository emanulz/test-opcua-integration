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
