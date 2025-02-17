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
OPC_ENDPOINT=''
STATE_NODE_ID=''
ITEM_ID_NODE_ID=''
RESULT_NODE_ID=''

# API environment variables
API_BASE_URL=''
API_USER=''
API_PASSWORD=''
API_WORKSPACE_ID=''
```

### Run the project for local development

```bash
yarn dev
```
