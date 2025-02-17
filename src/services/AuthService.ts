/**
 * @file AuthService.ts
 * @description AuthService repository for handling API authentication (login).
 */

import axios from 'axios';
import { envConfig } from '../configs/envConfig';
import { loginResponseSchema } from '../domain/models/loginResponseSchema';
import { IAuthService } from '../interfaces/IAuthService';
import { ITokenRepository } from '../interfaces/ITokenRepository';

export class AuthService implements IAuthService {
  private token: string | null = null;

  constructor(private tokenRepository: ITokenRepository) {}

  /**
   * Get a valid token. If none is available in memory or in the database, log in.
   * @returns A promise that resolves to a valid token string.
   */
  async getToken(): Promise<string> {
    // 1. If we don't have a token in memory, try to load from DB
    if (!this.token) {
      const latestToken = this.tokenRepository.getLatestToken();
      if (latestToken) {
        // TODO: Potentially check if it's expired. If not expired, use it.
        console.log('Found existing token in DB. Using it...');
        this.token = latestToken.token;
      }
    }

    // 2. If still no token (or you decided it's expired), log in fresh
    if (!this.token) {
      await this.login();
    }

    return this.token as string;
  }

  /**
   * Forces a re-login, discarding any cached token.
   */
  async refreshToken(): Promise<void> {
    this.token = null;
    await this.login();
  }

  /**
   * Logs in to obtain a new token, storing it in memory and the database.
   */
  private async login(): Promise<void> {
    try {
      console.log('Logging in to API...');
      const response = await axios.post(
        `${envConfig.API_BASE_URL}/login`,
        {
          email: envConfig.API_USER,
          password: envConfig.API_PASSWORD,
          workspaceId: envConfig.API_WORKSPACE_ID,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Arena-Usage-Reason': envConfig.API_USAGE_REASON,
          },
        }
      );

      // Validate response data with Zod
      const loginResponse = loginResponseSchema.parse(response.data);

      // Cache the token in memory
      this.token = loginResponse.arenaSessionId;

      // Save token to DB
      this.tokenRepository.saveToken(this.token, new Date());
      console.log('Login successful, token obtained and stored in DB.');
    } catch (error: any) {
      console.error('Login failed:', error.response?.data || error);
      throw error; // rethrow to handle upper-level logic
    }
  }
}
