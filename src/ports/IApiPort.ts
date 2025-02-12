/**
 * @file IApiPort.ts
 * @module ports/IApiPort
 */

/**
 * Interface for the API adapter.
 *
 * @remarks
 * This interface defines the contract for processing a barcode via an external API.
 */
export interface IApiPort {
  /**
   * Processes the given barcode by calling an external API.
   *
   * @param barcode - The barcode string received from the OPC UA server.
   * @returns A promise that resolves to a number representing the API response.
   */
  processBarcode(barcode: string): Promise<number>;
}
