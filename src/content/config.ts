import { defineCollection, z } from 'astro:content';

const posts = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.coerce.date(),
    updated: z.coerce.date().optional(),
    tags: z.array(z.string()),
    series: z.string().optional(),
    draft: z.boolean().optional().default(false),
    generated: z.boolean().optional().default(false),
    reviewed: z.boolean().optional().default(false),
  }),
});

export const collections = { posts };
