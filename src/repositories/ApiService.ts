/**
 * @file ApiService.ts
 * @description ApiService repository for fetching data from the external API using token-based auth.
 */

import axios, { AxiosError } from 'axios';
import { envConfig } from '../configs/envConfig';
import { ItemResponse, itemResponseSchema } from '../domain/models/itemResponseSchema';
import { IApiService } from '../interfaces/IApiService';
import { IAuthService } from '../interfaces/IAuthService';

export class ApiService implements IApiService {
  constructor(private authService: IAuthService) {}

  /**
   * Fetch an item by ID, validating the response with Zod.
   * If a 401 is encountered, re-login once and retry.
   */
  async getItemById(itemId: string): Promise<ItemResponse> {
    try {
      return await this.fetchItem(itemId);
    } catch (error) {
      // Check if it's a 401
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError;
        if (axiosError.response && axiosError.response.status === 401) {
          console.warn('Received 401, refreshing token...');
          await this.authService.refreshToken();
          // Retry once
          return await this.fetchItem(itemId);
        }
      }
      throw error;
    }
  }

  private async fetchItem(itemId: string): Promise<ItemResponse> {
    const token = await this.authService.getToken();

    const response = await axios.get(`${envConfig.API_BASE_URL}/items/${itemId}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    // Validate response data with Zod
    const parsed = itemResponseSchema.parse(response.data);
    return parsed;
  }
}
