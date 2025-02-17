/**
 * @file AuthService.ts
 * @description AuthService repository for handling API authentication (login).
 */

import axios from 'axios';
import { envConfig } from '../configs/envConfig';
import { IAuthService } from '../interfaces/IAuthService';

export class AuthService implements IAuthService {
  private token: string | null = null;

  /**
   * Get a valid token. If none is available, log in.
   * @returns A promise that resolves to a valid token string.
   */
  async getToken(): Promise<string> {
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
   * Logs in to obtain a new token, storing it in memory.
   */
  private async login(): Promise<void> {
    try {
      console.log('Logging in to API...');
      const response = await axios.post(`${envConfig.API_BASE_URL}/login`, {
        user: envConfig.API_USER,
        password: envConfig.API_PASSWORD,
        workspaceId: envConfig.API_WORKSPACE_ID,
      });

      // Assume response.data.token is the token
      this.token = response.data.token;
      console.log('Login successful, token obtained.');
    } catch (error) {
      console.error('Failed to log in:', error);
      throw error;
    }
  }
}
