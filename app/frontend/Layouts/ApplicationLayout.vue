<template>
  <Head :title="`ArxivReader - ${$page.props.head.title}`">
    <meta name="description">
    <meta name="keywords">
    <link
      rel="stylesheet"
      media="screen"
      href="https://cdn.jsdelivr.net/gh/jpswalsh/academicons/css/academicons.min.css"
    >
  </Head>

  <q-layout view="hHh LpR lFr">
  <q-header
    elevated
    class="bg-primary text-white"
    height-hint="98"
  >
    <q-toolbar>
      <left-drawer v-if="current_user">
        foobar
      </left-drawer>
      <q-toolbar-title id="pageTitle">{{ $page.props.head.title }}</q-toolbar-title>
    </q-toolbar>
  </q-header>

    <slot />

    <q-banner
      v-if="$page.props.flash.alert"
      inline-actions
      class="bg-warning"
    >
      {{ $page.props.flash.alert }}
    </q-banner>
    <q-banner
      v-if="$page.props.flash.notice"
      inline-actions
      class="bg-info"
    >
      {{ $page.props.flash.notice }}
    </q-banner>
    <q-banner
      v-if="$page.props.flash.error"
      inline-actions
      class="bg-accent"
    >
      {{ $page.props.flash.error }}
    </q-banner>
    <q-page-sticky
      position="bottom-right"
      :offset="[18, 18]"
    >
      <login-button />
    </q-page-sticky>
  </q-layout>
</template>

<script>
import LoginButton from '@/Layouts/Components/LoginButton.vue'
import LeftDrawer from '@/Components/LeftDrawer.vue'
import { Head } from '@inertiajs/vue3'
import userMixin from '@/mixins/userMixin'

export default {
  components: {
    Head,
    LoginButton,
    LeftDrawer,
  },
  mixins: [userMixin],
  data() {
    return {
    }
  },
  computed: {
  },
}
</script>
