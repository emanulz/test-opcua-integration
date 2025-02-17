/**
 * @file loginResponseSchema.ts
 * @description Zod schema for validating the login data response from the API.
 */

import { z } from 'zod';

export const loginResponseSchema = z.object({
  arenaSessionId: z.string(),
  workspaceId: z.number().optional(),
});

export type LoginResponse = z.infer<typeof loginResponseSchema>;
