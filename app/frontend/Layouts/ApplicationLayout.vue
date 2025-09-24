<template>
  <Head :title="$page.props.head.title">
    <meta name="description" />
    <meta name="keywords" />
    <link
      rel="stylesheet"
      media="screen"
      href="https://cdn.jsdelivr.net/gh/jpswalsh/academicons/css/academicons.min.css"
    />
  </Head>

  <q-layout view="hHh LpR lFr">

    <slot />

    <q-banner v-if="$page.props.flash.alert" inline-actions class="bg-warning">
        {{ $page.props.flash.alert }}
    </q-banner>
    <q-banner v-if="$page.props.flash.notice" inline-actions class="bg-info">
        {{ $page.props.flash.notice }}
    </q-banner>
    <q-banner v-if="$page.props.flash.error" inline-actions class="bg-accent">
        {{ $page.props.flash.error }}
    </q-banner>
    <q-page-sticky position="bottom-right" :offset="[18, 18]">
      <login-button />
    </q-page-sticky>

  </q-layout>
</template>

<script>
import LoginButton from '@/Layouts/Components/LoginButton.vue'
import { Head } from '@inertiajs/vue3'

export default {
  components: {
    Head,
    LoginButton,
  },
  data() {
    return {
    }
  },
  computed: {
  },
}
</script>
