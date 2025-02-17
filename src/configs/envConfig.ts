/**
 * @file envConfig.ts
 * @description Loads environment variables and exports them for the application.
 */

import 'dotenv/config';

export const envConfig = {
  // OPC server
  OPC_ENDPOINT: process.env.OPC_ENDPOINT || 'opc.tcp://localhost:4840',
  STATE_NODE_ID: process.env.STATE_NODE_ID || 'ns=2;s=StateMachineNode',
  ITEM_ID_NODE_ID: process.env.ITEM_ID_NODE_ID || 'ns=2;s=ItemIdNode',
  RESULT_NODE_ID: process.env.RESULT_NODE_ID || 'ns=2;s=ResultNode',

  // API
  API_BASE_URL: process.env.API_BASE_URL || 'https://your-api-endpoint.com',
  API_USER: process.env.API_USER || '',
  API_PASSWORD: process.env.API_PASSWORD || '',
  API_WORKSPACE_ID: process.env.API_WORKSPACE_ID || '',
};
