/**
 * @file DefaultApiAdapter.ts
 * @module adapters/api/DefaultApiAdapter
 */

import axios from 'axios';
import { IApiPort } from '../../ports/IApiPort';

/**
 * DefaultApiAdapter implements the IApiPort interface to call an external API.
 */
export class DefaultApiAdapter implements IApiPort {
  private baseUrl: string;

  /**
   * Creates an instance of DefaultApiAdapter.
   *
   * @param baseUrl - The base URL of the external API.
   */
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  /**
   * Processes the barcode by calling the external API.
   *
   * @param barcode - The barcode string to be processed.
   * @returns A promise that resolves to a number representing the API response.
   */
  async processBarcode(barcode: string): Promise<number> {
    try {
      const response = await axios.get(`${this.baseUrl}/objects/7`, {
        params: { barcode },
      });
      // Assume the API returns an object like { result: number }
      return response.data.result;
    } catch (error) {
      console.error('Error calling external API:', error);
      throw error;
    }
  }
}
