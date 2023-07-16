// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
//import ActiveStorage from '@rails/activestorage'
////ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import { Quasar, Notify } from 'quasar'
import quasarIconSet from 'quasar/icon-set/mdi-v7'

// Import icon libraries
import '@quasar/extras/mdi-v7/mdi-v7.css'

// Import Quasar css
import 'quasar/src/css/index.sass'

import ApplicationLayout from '@/Layouts/ApplicationLayout.vue'

const pages = import.meta.glob('../Pages/**/*.vue', { eager: true })

createInertiaApp({
  resolve: name => {
    let page = pages[`../Pages/${name}.vue`]
    page.default.layout = page.default.layout || ApplicationLayout
    return page
  },
  setup({ el, App, props, plugin }) {
    createApp({ render: () => h(App, props) })
      .use(plugin)
      .use(Quasar, {
        config: {
        notify: {},
        brand: {
          primary: '#027be3',
          secondary: '#26a69a',
          accent: '#9c27b0',
          dark: '#1d1d1d',
          positive: '#21ba45',
          negative: '#c10015',
          info: '#31ccec',
          warning: '#f2c037',
        },
      },
      plugins: {
        Notify,
      },
      iconSet: quasarIconSet,
      })
      .mount(el)
  },
})

