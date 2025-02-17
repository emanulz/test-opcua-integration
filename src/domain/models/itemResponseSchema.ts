/**
 * @file itemResponseSchema.ts
 * @description Zod schema for validating the item data response from the API.
 */

import { z } from 'zod';

export const itemResponseSchema = z.object({
  guid: z.string(),
  assemblyType: z.string(),
  lifecyclePhase: z.object({
    guid: z.string(),
    name: z.string(),
  }),
});

export type ItemResponse = z.infer<typeof itemResponseSchema>;
