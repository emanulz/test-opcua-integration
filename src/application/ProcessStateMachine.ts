/**
 * @file ProcessStateMachine.ts
 * @description Coordinates the state machine logic and API calls.
 */

import { envConfig } from '../configs/envConfig';
import { ItemNotFoundError } from '../domain/errors/ItemNotFoundError';
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
   * If the state matches START_STATE_VALUE, we read the itemId, fetch from API, write to the result node,
   * and then update the state to DONE_STATE_VALUE.
   *
   * @param newState - The new value of the state node.
   */
  private async handleStateChange(newState: string): Promise<void> {
    console.log('State machine changed to:', newState);
    if (newState === envConfig.START_STATE_VALUE) {
      try {
        // Reset error code to NO_ERROR_CODE when starting
        await this.opcServer.writeValue(envConfig.ERROR_NODE_ID, envConfig.NO_ERROR_CODE);

        // 1. Read the itemId from the OPC server
        const itemIdValue = await this.opcServer.readValue(envConfig.ITEM_ID_NODE_ID);
        if (!itemIdValue) {
          console.error('No itemId found on OPC server.');
          await this.opcServer.writeValue(envConfig.ERROR_NODE_ID, envConfig.GENERAL_ERROR_CODE);
          await this.opcServer.writeValue(envConfig.STATE_NODE_ID, envConfig.DONE_STATE_VALUE);
          return;
        }
        const itemId = String(itemIdValue);

        // 2. Fetch the item from the API
        console.log('Fetching item from API, itemId:', itemId);
        const itemData = await this.apiService.getItemById(itemId);

        // 3. Write the result to the RESULT_NODE_ID as an array
        const resultArray = [itemData.lifecyclePhase.name, 'Test Value 1', 'Test Value 2', 'Test Value 3'];
        await this.opcServer.writeValue(envConfig.RESULT_NODE_ID, resultArray);

        // 4. Update the state node to DONE_STATE_VALUE
        await this.opcServer.writeValue(envConfig.STATE_NODE_ID, envConfig.DONE_STATE_VALUE);
      } catch (error) {
        console.error('Error in state machine process:', error);

        // Handle specific error types
        if (error instanceof ItemNotFoundError) {
          await this.opcServer.writeValue(envConfig.ERROR_NODE_ID, error.code);
        } else {
          await this.opcServer.writeValue(envConfig.ERROR_NODE_ID, envConfig.GENERAL_ERROR_CODE);
        }

        // Set state to DONE even when there's an error
        await this.opcServer.writeValue(envConfig.STATE_NODE_ID, envConfig.DONE_STATE_VALUE);
      }
    }
  }
}
