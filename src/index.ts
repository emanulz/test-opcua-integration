/**
 * @file index.ts
 * @description Application entry point.
 */

import { ProcessStateMachine } from './application/ProcessStateMachine';
import { ApiService } from './repositories/ApiService';
import { AuthService } from './repositories/AuthService';
import { OpcServerService } from './services/OpcServerService';

async function main() {
  // Create AuthService, then use it in ApiService
  const authService = new AuthService();
  const apiService = new ApiService(authService);

  // Create the OPC server service
  const opcServerService = new OpcServerService();

  // Create the use case
  const processSM = new ProcessStateMachine(opcServerService, apiService);

  // Initialize
  try {
    await processSM.initialize();
    console.log('State machine process initialized. Waiting for state changes...');
  } catch (err) {
    console.error('Failed to initialize the process state machine:', err);
    process.exit(1);
  }
}

main();

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down...');
  process.exit(0);
});
