/**
 * @file index.ts
 * @module index
 *
 * @remarks
 * Application entry point. Initializes the OPC UA and API adapters, sets up the process use case,
 * and starts listening for OPC UA events.
 */
import 'dotenv/config';
import { DefaultApiAdapter } from './adapters/api/DefaultApiAdapter';
import { GenericOpcuaAdapter } from './adapters/plc/GenericOpcuaAdapter';
import { ProcessBarcodeUseCase } from './application/ProcessBarcodeUseCase';

/**
 * Main function to bootstrap the application.
 */
async function main(): Promise<void> {
  // Retrieve the external API base URL from the environment variables
  const apiBaseUrl = process.env.API_BASE_URL;

  if (!apiBaseUrl) {
    console.error('API_BASE_URL environment variable is not set.');
    process.exit(1);
  }

  const opcuaAdapter = new GenericOpcuaAdapter();
  const apiAdapter = new DefaultApiAdapter(apiBaseUrl);
  const processBarcodeUseCase = new ProcessBarcodeUseCase(opcuaAdapter, apiAdapter);

  try {
    await processBarcodeUseCase.initialize();
    console.log('Process initialized. Listening for OPC UA events...');
  } catch (error) {
    console.error('Failed to initialize process:', error);
    process.exit(1);
  }
}

// Start the application.
main();

// Optional: Handle graceful shutdown.
process.on('SIGINT', async () => {
  console.log('Shutting down application...');
  // Insert any cleanup logic if needed (e.g., closing OPC UA session)
  process.exit(0);
});
