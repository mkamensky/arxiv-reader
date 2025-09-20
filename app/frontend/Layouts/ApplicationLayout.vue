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

  <slot />
 </template>

<script>
import { Head } from '@inertiajs/vue3'

export default {
  components: {
    Head,
  },
}
</script>
