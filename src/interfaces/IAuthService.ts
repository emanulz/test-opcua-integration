/**
 * @file IAuthService.ts
 * @description Interface for handling authentication to the external API.
 */

export interface IAuthService {
  /**
   * Returns a valid token. If the current token is expired or invalid, it should re-authenticate.
   */
  getToken(): Promise<string>;

  /**
   * Forces a re-login, discarding any cached token.
   */
  refreshToken(): Promise<void>;
}
