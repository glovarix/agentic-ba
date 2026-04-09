import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://glovarix.github.io',
  base: '/agentic-ba',
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
});
