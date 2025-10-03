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
      <q-toolbar glossy>
        <q-btn
          flat
          class="bg-accent"
          :icon="icon"
          @click="drawerOpen = !drawerOpen"
        />
        <q-toolbar-title>{{ $page.props.head.title }}</q-toolbar-title>
        <q-input
          v-model="query"
          outlined
          class="bg-info"
          label="Search"
          type="search"
          stack-label
          clearable
          @keyup.enter="search"
        >
          <template #append>
            <q-icon name="$search" @click="search" />
          </template>
        </q-input>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="drawerOpen"
      show-if-above
      side="left"
      bordered
      column
      class="text-black"
    >
      <user-card v-if="current_user" />
      <login-form v-else />
    </q-drawer>

    <q-page-container>
      <slot />
    </q-page-container>

    <q-banner v-if="$page.props.flash.alert" inline-actions class="bg-warning">
      {{ $page.props.flash.alert }}
    </q-banner>
    <q-banner v-if="$page.props.flash.notice" inline-actions class="bg-info">
      {{ $page.props.flash.notice }}
    </q-banner>
    <q-banner v-if="$page.props.flash.error" inline-actions class="bg-accent">
      {{ $page.props.flash.error }}
    </q-banner>
  </q-layout>
</template>

<script>
import LoginForm from '@/Layouts/Components/LoginForm.vue'
import UserCard from '@/Layouts/Components/UserCard.vue'
import { Head, router } from '@inertiajs/vue3'
import userMixin from '@/mixins/userMixin'

export default {
  components: {
    Head,
    LoginForm,
    UserCard,
  },
  mixins: [userMixin],
  data() {
    return {
      drawerOpen: false,
      query: '',
    }
  },
  computed: {
    icon() {
      if (this.current_user) {
        return this.current_user.avatar.length > 0 ?
          `img:${this.current_user.avatar}` : '$loggedin'
      } else {
        return '$login'
      }
    },
  },
  methods: {
    search() {
      router.get(this.$index_path('papers'), {q: this.query})
    },
  },
}
</script>
