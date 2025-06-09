/**
 * @file IOpcServerService.ts
 * @description Interface for interacting with an OPC server.
 */

export interface IOpcServerService {
  /**
   * Connect to the OPC server.
   */
  connect(): Promise<void>;

  /**
   * Check if the OPC server is currently connected.
   */
  isOpcServerConnected(): boolean;

  /**
   * Subscribe to changes in a "state" node. When triggered, it calls the callback with the new state.
   * @param callback - function to handle changes in the state node
   */
  subscribeToStateChanges(callback: (newState: string) => void): void;

  /**
   * Read a value from the OPC server (e.g., itemId node).
   * @param nodeId - Node to read from
   */
  readValue(nodeId: string): Promise<string | number | null>;

  /**
   * Write a value to the OPC server (e.g., result or state node).
   * @param nodeId - Node to write to
   * @param value - Value to write
   */
  writeValue(nodeId: string, value: unknown): Promise<void>;
}
