<template>
  <Head :title="`ArxivReader - ${$page.props.head.title}`">
    <meta name="description" content="A frontend to the ArXiv, allowing bookmarking articles and authors, and filtering by categories">
    <meta name="keywords">
    <link
      rel="stylesheet"
      media="screen"
      href="https://cdn.jsdelivr.net/gh/jpswalsh/academicons/css/academicons.min.css"
    >
  </Head>

  <q-layout view="hHh LpR lFr">
    <q-header elevated class="bg-primary text-white" height-hint="98">
      <q-toolbar
        class="glossy q-px-xs justify-between q-gutter-y-xs"
        style="flex-wrap: wrap;max-width: 100vw"
      >
        <div class="col-12 col-md row justify-between">
          <div class="col q-gutter-x-sm">
            <q-btn
              flat
              class="bg-accent"
              :icon="icon"
              title="Toggle sidebar"
              @click="drawerOpen = !drawerOpen"
            />
            <q-btn
              icon="$home"
              href="/"
              title="Home"
              class="bg-accent"
            />
          </div>
          <q-toolbar-title class="col row inline">
            {{ $page.props.head.title }}
          </q-toolbar-title>
        </div>
        <div class="col-12 col-md-auto row">
          <q-input
            v-for="what in ['authors', 'papers']"
            :key="what"
            v-model="query[what]"
            outlined
            dense
            class="bg-info col-12 col-sm-6"
            :label="`Search ${what}`"
            type="search"
            stack-label
            clearable
            @keyup.enter="search(what)"
          >
            <template #append>
              <q-icon name="$search" @click="search(what)" />
            </template>
          </q-input>
        </div>
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
import { Loading } from 'quasar'
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
      query: {
        papers: '',
        authors: '',
      }
    }
  },
  computed: {
    icon() {
      if (this.current_user) {
        return this.current_user.avatar?.length ?
          `img:${this.current_user.avatar}` : '$loggedin'
      } else {
        return '$login'
      }
    },
  },
  methods: {
    search(what) {
      router.get(this.$index_path(what), {q: this.query[what]}, {
        onStart() { Loading.show({ delay: 100 }) },
        onFinish() { Loading.hide() },
      })
    },
  },
}
</script>
