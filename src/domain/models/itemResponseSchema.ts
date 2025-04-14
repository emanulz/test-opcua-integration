/**
 * @file itemResponseSchema.ts
 * @description Zod schema for validating the item data response from the API.
 */

import { z } from 'zod';

const urlSchema = z.object({
  api: z.string(),
  app: z.string(),
});

const categorySchema = z.object({
  guid: z.string(),
  name: z.string(),
});

const lifecyclePhaseSchema = z.object({
  guid: z.string(),
  name: z.string(),
});

const itemSchema = z.object({
  assemblyType: z.string(),
  category: categorySchema,
  creationDateTime: z.string(),
  guid: z.string(),
  inAssembly: z.boolean(),
  lifecyclePhase: lifecyclePhaseSchema,
  name: z.string(),
  number: z.string(),
  revisionNumber: z.string(),
  revisionStatus: z.string(),
  url: urlSchema,
});

export const itemResponseSchema = z.object({
  count: z.number(),
  results: z.array(itemSchema),
});

export type ItemResponse = z.infer<typeof itemSchema>;
