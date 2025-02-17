/**
 * @file IApiService.ts
 * @description Interface for making API calls using token-based authentication.
 */

import { ItemResponse } from '../domain/models/itemResponseSchema';

export interface IApiService {
  /**
   * Fetch an item from the API by its ID. Requires a valid token.
   * @param itemId - ID of the item to fetch.
   * @returns The validated item data.
   */
  getItemById(itemId: string): Promise<ItemResponse>;
}
