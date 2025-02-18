/**
 * @file ProcessStateMachine.ts
 * @description Coordinates the state machine logic and API calls.
 */

import { envConfig } from '../configs/envConfig';
import { IApiService } from '../interfaces/IApiService';
import { IOpcServerService } from '../interfaces/IOpcServerService';

export class ProcessStateMachine {
  constructor(
    private opcServer: IOpcServerService,
    private apiService: IApiService
  ) {}

  /**
   * Initializes the process by connecting to the OPC server,
   * and subscribing to state changes.
   */
  async initialize(): Promise<void> {
    await this.opcServer.connect();
    this.opcServer.subscribeToStateChanges((newState) => this.handleStateChange(newState));
  }

  /**
   * Called whenever the state node changes.
   * If the state is "START", we read the itemId, fetch from API, write to the result node,
   * and then update the state to "DONE".
   *
   * @param newState - The new value of the state node.
   */
  private async handleStateChange(newState: string): Promise<void> {
    console.log('State machine changed to:', newState);
    if (newState === 'START') {
      try {
        // 1. Read the itemId from the OPC server
        const itemIdValue = await this.opcServer.readValue(envConfig.ITEM_ID_NODE_ID);
        if (!itemIdValue) {
          console.error('No itemId found on OPC server.');
          return;
        }
        const itemId = String(itemIdValue);

        // 2. Fetch the item from the API
        console.log('Fetching item from API, itemId:', itemId);
        const itemData = await this.apiService.getItemById(itemId);

        // 3. Write the result to the RESULT_NODE_ID
        // For demonstration, let's say we write the `name` field
        await this.opcServer.writeValue(envConfig.RESULT_NODE_ID, itemData.lifecyclePhase.name);

        // 4. Update the state node to "DONE"
        await this.opcServer.writeValue(envConfig.STATE_NODE_ID, 'DONE');
      } catch (error) {
        console.error('Error in state machine process:', error);
        // Optionally set error state in the OPC server
        await this.opcServer.writeValue(envConfig.STATE_NODE_ID, 'ERROR');
      }
    }
  }
}
