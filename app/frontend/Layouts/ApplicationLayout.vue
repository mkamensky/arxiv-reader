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
    <q-header elevated class="bg-primary text-white" height-hint="98">
      <q-toolbar>
        <q-btn
          dense
          flat
          round
          icon="$menu"
          @click="leftDrawerOpen = !leftDrawerOpen"
        />

        <q-toolbar-title>Recent ArXiv submissions</q-toolbar-title>

        <q-btn
          dense
          flat
          round
          icon="$menu"
          @click="rightDrawerOpen = !rightDrawerOpen"
        />
      </q-toolbar>
      <q-tabs
        align="justify"
        outside-arrows
        indicator-color="red"
        color="yellow"
        active-color="red"
        active-class="active"
        shrink
        stretch
        inline-label
        no-caps
      >
        <q-route-tab
          v-for="item in cats"
          :key="item"
          :name="item"
          :label="item"
          :href="`/categories/${item}`"
          :class="{
            'q-tab--active': $page.url === `/categories/${item}`,
          }"
        />
      </q-tabs>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      side="left"
      bordered
      column
    >
      <div class="q-pa-md relative-position">
        <h6 class="q-ma-sm">Categories</h6>
        <q-option-group
          v-model="cats"
          :options="categories"
          type="toggle"
          class="scroll overflow-auto"
          style="max-height: 500px"
        />
      </div>
    </q-drawer>

    <q-drawer v-model="rightDrawerOpen" side="right" overlay elevated>
      <!-- drawer content -->
    </q-drawer>

    <q-page-container>
      <slot />
    </q-page-container>

    <q-footer reveal elevated class="bg-grey-8 text-white">
      <q-toolbar>
        <q-toolbar-title>
          <div>Title</div>
        </q-toolbar-title>
      </q-toolbar>
    </q-footer>
  </q-layout>
</template>

<script>
import { Head } from '@inertiajs/vue3'

export default {
  components: {
    Head,
  },
  props: {
    categories: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      leftDrawerOpen: false,
      rightDrawerOpen: false,
      cats:
        this.$q.localStorage.getItem('cats') ||
        this.categories.map((cat) => cat.value),
    }
  },
  watch: {
    cats: {
      handler(val) {
        this.$q.localStorage.set('cats', val)
      },
      immediate: true,
    },
  },
}
</script>
