/**
 * @file ITokenRepository.ts
 * @description Interface for storing and retrieving tokens in a database.
 */
import { TokenRecord } from '../domain/models/TokenRecord';

export interface ITokenRepository {
  /**
   * Retrieves the latest token record from storage.
   * Returns null if no token is found.
   */
  getLatestToken(): TokenRecord | null;

  /**
   * Saves a new token record (token + createdAt).
   */
  saveToken(token: string, createdAt: Date): void;
}
