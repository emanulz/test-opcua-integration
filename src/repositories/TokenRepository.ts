/**
 * @file TokenRepository.ts
 * @description Stores and retrieves tokens from a local SQLite database.
 */

import Database from 'better-sqlite3';
import { ITokenRepository } from '../interfaces/ITokenRepository';
import { TokenRecord } from '../domain/models/TokenRecord';

export class TokenRepository implements ITokenRepository {
  private db: Database.Database;

  constructor(dbPath: string) {
    this.db = new Database(dbPath);
    this.initialize();
  }

  private initialize(): void {
    // 1. Create the tokens table if it doesn't exist
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    `);

    // 2. Create an index on createdAt to optimize "ORDER BY createdAt DESC"
    this.db.exec(`
      CREATE INDEX IF NOT EXISTS idx_tokens_createdAt
      ON tokens (createdAt);
    `);
  }

  /**
   * Retrieves the latest token record from the tokens table,
   * ordered by createdAt descending.
   */
  getLatestToken(): TokenRecord | null {
    const row = this.db.prepare('SELECT * FROM tokens ORDER BY createdAt DESC LIMIT 1').get() as TokenRecord;

    if (!row) return null;

    return {
      id: row.id,
      token: row.token,
      createdAt: new Date(row.createdAt),
    };
  }

  /**
   * Saves a new token record into the tokens table.
   */
  saveToken(token: string, createdAt: Date): void {
    this.db.prepare('INSERT INTO tokens (token, createdAt) VALUES (?, ?)').run(token, createdAt.toISOString());
  }
}
