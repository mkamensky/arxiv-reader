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

console.log(
  'Visit the guide for more information: ',
  'https://vite-ruby.netlify.app/guide/rails',
)

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
import { createInertiaApp, Link } from '@inertiajs/vue3'
import { Quasar, Notify, LocalStorage } from 'quasar'

import MarkdownIt from 'markdown-it'
import mk from '@traptitech/markdown-it-katex'
const markdown = new MarkdownIt().set({ linkify: true }).use(mk)

import quasarIconSet from 'quasar/icon-set/mdi-v7'
import routes from '@/api'

// Import icon libraries
import '@quasar/extras/mdi-v7/mdi-v7.css'

// Import Quasar css
import 'quasar/src/css/index.sass'

import ApplicationLayout from '@/Layouts/ApplicationLayout.vue'

const myIcons = {
  scopus: { cls: 'ai ai-scopus' },
  gs: { cls: 'ai ai-google-scholar' },
  wos: { cls: 'ai ai-wos' },
  arxiv: { cls: 'ai ai-arxiv' },
  orcid: { cls: 'ai ai-orcid' },
  mathscinet: { cls: 'ai ai-mathscinet' },
  pure: { cls: 'ai ai-bgupure' }, // TODO
  email: 'mdi-email',
  fax: 'mdi-fax',
  building: 'mdi-warehouse',
  phone: 'mdi-phone-classic',
  office: 'mdi-door-closed',
  snail: 'mdi-card-account-mail',
  edit: 'mdi-pencil',
  noedit: 'mdi-pencil-off',
  delete: 'mdi-delete',
  deleteOutline: 'mdi-delete-outline',
  hide: 'mdi-chevron-up',
  show: 'mdi-chevron-down',
  right: 'mdi-chevron-right',
  left: 'mdi-chevron-left',
  close: 'mdi-close',
  calendar: 'mdi-calendar',
  time: 'mdi-clock-outline',
  select: 'mdi-checkbox-marked-circle-outline',
  unselect: 'mdi-radiobox-blank',
  home: 'mdi-home',
  closeDrawer: 'mdi-menu-open',
  alert: 'mdi-alert-octagram',
  login: 'mdi-account-question',
  menu: 'mdi-menu',
  admin: 'mdi-cogs',
  help: 'mdi-help-box',
  enter: 'mdi-login',
  visible: 'mdi-eye',
  invisible: 'mdi-eye-off',
  loggedin: 'mdi-account-check',
  userpage: 'mdi-account',
  star: 'mdi-star',
  starAdd: 'mdi-star-plus-outline',
  starRemove: 'mdi-star-remove',
  search: 'mdi-magnify',
  rotateLeft: 'mdi-rotate-left',
  rotateRight: 'mdi-rotate-right',
  flipVertical: 'mdi-flip-vertical',
  flipHorizontal: 'mdi-flip-horizontal',
  add: 'mdi-plus',
  web: 'mdi-web',
  bulletRight: 'mdi-hand-pointing-right',
  bulletLeft: 'mdi-hand-pointing-left',
  minus: 'mdi-minus-box',
  plus: 'mdi-plus-box',
  check: 'mdi-check-circle',
  cancel: 'mdi-close-circle',
  update: 'mdi-update',
  send: 'mdi-send',
  pdf: 'mdi-file-pdf-box',
  download: 'mdi-download-box',
  event: 'mdi-calendar-today',
  menuLeft: 'mdi-menu-left',
  menuRight: 'mdi-menu-right',
  bookmarkOn: 'mdi-bookmark-check-outline',
  bookmark: 'mdi-bookmark-outline',
  comment: 'mdi-comment-text-outline',
}

const pages = import.meta.glob('../Pages/**/*.vue', { eager: true })

createInertiaApp({
  resolve: (name) => {
    let page = pages[`../Pages/${name}.vue`]
    page.default.layout = page.default.layout || ApplicationLayout
    return page
  },
  setup({ el, App, props, plugin }) {
    const app = createApp({ render: () => h(App, props) })
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
          LocalStorage,
        },
        iconSet: quasarIconSet,
      })
      .component('Link', Link)
      .component('RouterLink', {
        functional: true,
        render(page, context) {
          const props = page.$attrs || {}
          props.href ??= props.to
          return h('Link', props, context)
        },
      })
    app.config.globalProperties.$show_path = function (what, id) {
      return routes[what].show.path({ id: id })
    }
    app.config.globalProperties.$update_path = function (what, id) {
      return routes[what].update.path({ id: id })
    }
    app.config.globalProperties.$create_path = function (what) {
      return routes[what].create.path()
    }
    app.config.globalProperties.$index_path = function (what) {
      return routes[what].index.path()
    }
    const premkdn = (it) => (it || '').toString().replace(/--/g, '\u2013')
    app.config.globalProperties.$md = (mkdn) => markdown.render(premkdn(mkdn))
    app.config.globalProperties.$mdi = (mkdn) =>
      markdown.renderInline(premkdn(mkdn))
    app.config.globalProperties.$q.iconMapFn = (iname) => {
      if (iname.startsWith('$')) {
        const res = myIcons[iname.substring(1)]
        return typeof res === 'string' ? { icon: res } : res
      }
    }

    app.mount(el)
  },
})
