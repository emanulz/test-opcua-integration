/**
 * @file dotenv.ts
 * @description Configures dotenv with explicit path
 */

import * as dotenv from 'dotenv';
import * as fs from 'fs';
import * as path from 'path';

// Try multiple possible locations for .env file
const possiblePaths = [
  path.resolve(process.cwd(), '.env'),
  path.resolve('/app/.env'),
  path.resolve('../.env'),
  path.resolve('../../.env'),
];

for (const envPath of possiblePaths) {
  if (fs.existsSync(envPath)) {
    console.log(`Loading environment variables from: ${envPath}`);
    dotenv.config({ path: envPath });
    break;
  }
}

// Log environment variables for debugging (excluding sensitive ones)
console.log('Environment variables loaded:');
console.log('OPC_ENDPOINT:', process.env.OPC_ENDPOINT);
console.log('STATE_NODE_ID:', process.env.STATE_NODE_ID);
console.log('ITEM_ID_NODE_ID:', process.env.ITEM_ID_NODE_ID);
// Don't log sensitive variables like passwords
