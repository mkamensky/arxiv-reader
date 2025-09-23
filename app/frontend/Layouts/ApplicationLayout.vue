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
  <q-page-sticky position="bottom-right" :offset="[18, 18]">
    <q-fab
      icon="add"
      direction="up"
      color="accent"
      >
      <q-fab-action @click="onClick" color="primary" icon="person_add" />
        <q-fab-action @click="onClick" color="primary" icon="mail" />
        </q-fab>
  </q-page-sticky>

  </q-layout>
</template>

<script>
import { Head } from '@inertiajs/vue3'

export default {
  components: {
    Head,
  },
}
</script>
