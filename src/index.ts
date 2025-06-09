/**
 * @file index.ts
 * @description Application entry point.
 */

import { ProcessStateMachine } from './application/ProcessStateMachine';
import { TokenRepository } from './repositories/TokenRepository';
import { ApiService } from './services/ApiService';
import { AuthService } from './services/AuthService';
import { OpcServerService } from './services/OpcServerService';

async function main() {
  // Create AuthService, then use it in ApiService
  const tokenRepository = new TokenRepository('./tokens.db');
  const authService = new AuthService(tokenRepository);
  const apiService = new ApiService(authService);

  // Create the OPC server service
  const opcServerService = new OpcServerService();

  // Create the use case
  const processSM = new ProcessStateMachine(opcServerService, apiService);

  // Initialize - don't exit on OPC connection failure, let it retry
  try {
    await processSM.initialize();
    console.log('State machine process initialized. Waiting for state changes...');
  } catch (err) {
    console.error('Failed to initialize the process state machine:', err);
    console.log('Application will continue running and attempt to reconnect to OPC server...');

    // Don't exit - let the OpcServerService handle reconnection
    // The subscription will be set up once connection is established
    processSM.initializeWithRetry();
  }
}

main();

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down...');
  process.exit(0);
});
