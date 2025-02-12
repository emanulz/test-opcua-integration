/**
 * @file ProcessBarcodeUseCase.ts
 * @module application/ProcessBarcodeUseCase
 */

import { IPlcPort } from '../ports/IPlcPort';
import { IApiPort } from '../ports/IApiPort';

/**
 * ProcessBarcodeUseCase coordinates the overall process:
 * - It listens for OPC UA events,
 * - Calls the external API when an event (barcode) is detected,
 * - And writes the API response back to the OPC UA server.
 */
export class ProcessBarcodeUseCase {
  private plcAdapter: IPlcPort;
  private apiAdapter: IApiPort;

  /**
   * Creates an instance of ProcessBarcodeUseCase.
   *
   * @param plcAdapter - The OPC UA adapter implementing IPlcPort.
   * @param apiAdapter - The API adapter implementing IApiPort.
   */
  constructor(plcAdapter: IPlcPort, apiAdapter: IApiPort) {
    this.plcAdapter = plcAdapter;
    this.apiAdapter = apiAdapter;
  }

  /**
   * Initializes the process by connecting to the OPC UA server and subscribing to events.
   *
   * When an OPC UA event is detected, the external API is called with the barcode,
   * and its response is then written back to the OPC UA server.
   *
   * @returns A promise that resolves when initialization is complete.
   */
  async initialize(): Promise<void> {
    await this.plcAdapter.connect();
    this.plcAdapter.subscribe(async (barcode: string) => {
      console.log('Processing barcode:', barcode);
      try {
        const apiResponse = await this.apiAdapter.processBarcode(barcode);
        console.log('IRRR A TOMAR X2!!');
        console.log('API response--->:', apiResponse);
        await this.plcAdapter.writeResponse(apiResponse);
      } catch (error) {
        console.error('Error processing barcode event:', error);
      }
    });
  }
}
