import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://www.thedatadrivenlife.com',
  base: '/',
  output: 'static',
  trailingSlash: 'always',

  server: {
    host: true
  },

  vite: {
    plugins: [tailwindcss()],
  },

  build: {
    assets: '_assets',
  },

  integrations: [
    sitemap({
      // Keep the unlisted training assessment out of the sitemap.
      filter: (page) => !page.includes('/assessment-abaf-7k39fa2x/'),
    }),
  ],
});