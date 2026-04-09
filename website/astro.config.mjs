import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

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
});
