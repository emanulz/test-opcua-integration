/**
 * @file ItemNotFoundError.ts
 * @description Custom error class for when no items are found in the API response.
 */

import { envConfig } from '../../configs/envConfig';

export class ItemNotFoundError extends Error {
  public readonly code: number;

  constructor(message: string = 'No item found') {
    super(message);
    this.name = 'ItemNotFoundError';
    this.code = envConfig.ITEM_NOT_FOUND_ERROR_CODE;
  }
}
