import { defineConfig } from 'vite'
//import RubyPlugin from 'vite-plugin-ruby'
//import FullReload from 'vite-plugin-full-reload'
import vue from '@vitejs/plugin-vue'
import ViteRails from 'vite-plugin-rails'
import { quasar, transformAssetUrls } from '@quasar/vite-plugin'

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    manifest: true,
    minify: true,
    sourcemap: true,
    rollupOptions: {
      maxParallelFileOps: 1,
      output: {
        manualChunks: (id) => {
          if (id.includes("node_modules")) {
            return "vendor";
          }
        },
        sourcemapIgnoreList: (relativeSourcePath) => {
          return relativeSourcePath.includes("node_modules");
        },
      },
      input: {
        application: 'app/frontend/entrypoints/application.js',
      },
    },
  },
  server: {
    fs: {
      strict: false,
    },
  },
  optimizeDeps: {
    include: ['@inertiajs/vue3'],
  },
  plugins: [
    //RubyPlugin(),
    vue({
      template: {
        transformAssetUrls,
        compilerOptions: {
          isCustomElement: () => false,
        },
      }
    }),
    ViteRails({
      fullReload: {
        additionalPaths: ['config/routes.rb', 'app/views/**/*'],
      },
    }),
    quasar({
      autoImportComponentCase: 'combined',
    }),
    //FullReload(['config/routes.rb', 'app/views/**/*']),
  ],
})
