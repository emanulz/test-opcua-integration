/**
 * @file TokenRecord.ts
 * @description Describes the shape of the token record stored in SQLite.
 */
export interface TokenRecord {
  id?: number;
  token: string;
  createdAt: Date;
}
