import pluginVue from 'eslint-plugin-vue'
import globals from 'globals'

import { defineConfig, globalIgnores, } from "eslint/config"

import js from "@eslint/js";

export  default defineConfig([
  {
    plugins: {
      js,
    },

    extends: [
      "js/recommended",
      //"eslint:recommended",
      ...pluginVue.configs['flat/recommended'],
      //"prettier",
      //"plugin:prettier/recommended",
    ],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.amd,
      },

      sourceType: "module",
      ecmaVersion: "latest",
      parserOptions: {},
    },

    rules: {
      "vue/no-unused-vars": "error",
      //"vue/script-setup-uses-vars": "error",
      "vue/multi-word-component-names": "off",
      "vue/require-default-prop": "off",
      "vue/no-reserved-component-names": "off",
      "vue/no-v-text-v-html-on-component": "off",
      "vue/no-v-html": "off",
      "vue/max-attributes-per-line": ["warn", {"singleline" : 3}],
      "no-console": process.env.NODE_ENV === "production" ? "error" : "off",
      "no-debugger": process.env.NODE_ENV === "production" ? "error" : "off",
    },
  }, globalIgnores(["app/javascript/utils/routes.js", "node_modules", "public", "vendor"])])
