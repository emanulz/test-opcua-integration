/**
 * @file itemResponseSchema.ts
 * @description Zod schema for validating the item data response from the API.
 */

import { z } from 'zod';

export const itemResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
  // Add additional fields as needed
});

export type ItemResponse = z.infer<typeof itemResponseSchema>;
