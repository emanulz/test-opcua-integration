/**
 * @file envConfig.ts
 * @description Loads environment variables and exports them for the application.
 */

import 'dotenv/config';

export const envConfig = {
  // OPC server
  OPC_ENDPOINT: process.env.OPC_ENDPOINT || '',
  STATE_NODE_ID: process.env.STATE_NODE_ID || '',
  ITEM_ID_NODE_ID: process.env.ITEM_ID_NODE_ID || '',
  RESULT_NODE_ID: process.env.RESULT_NODE_ID || '',
  ERROR_NODE_ID: process.env.ERROR_NODE_ID || '',
  START_STATE_VALUE: process.env.START_STATE_VALUE || 'START',
  DONE_STATE_VALUE: process.env.DONE_STATE_VALUE || 'DONE',
  NO_ERROR_CODE: parseInt(process.env.NO_ERROR_CODE || '0', 10),
  GENERAL_ERROR_CODE: parseInt(process.env.GENERAL_ERROR_CODE || '9', 10),

  // API
  API_BASE_URL: process.env.API_BASE_URL || '',
  API_USER: process.env.API_USER || '',
  API_PASSWORD: process.env.API_PASSWORD || '',
  API_WORKSPACE_ID: process.env.API_WORKSPACE_ID || '',
  API_USAGE_REASON: process.env.API_USAGE_REASON || '',
};
