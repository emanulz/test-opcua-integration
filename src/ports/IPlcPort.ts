/**
 * @file IPlcPort.ts
 * @module ports/IPlcPort
 */

/**
 * Interface for the OPC UA adapter.
 *
 * @remarks
 * This interface defines the contract for connecting to an OPC UA server, subscribing to events,
 * and writing responses back.
 */
export interface IPlcPort {
  /**
   * Connects to the OPC UA server.
   *
   * @returns A promise that resolves when the connection is established.
   */
  connect(): Promise<void>;

  /**
   * Subscribes to OPC UA tag changes.
   *
   * @param callback - A function that is called with the barcode string when a change is detected.
   */
  subscribe(callback: (barcode: string) => void): void;

  /**
   * Writes the API response back to the OPC UA server.
   *
   * @param response - The response value from the external API.
   * @returns A promise that resolves when the write operation is complete.
   */
  writeResponse(response: number): Promise<void>;
}
