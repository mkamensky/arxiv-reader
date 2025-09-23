<template>
  <q-header elevated class="bg-primary text-white" height-hint="98">
    <q-toolbar>
      <q-btn
        dense
        flat
        rounded
        icon="$menu"
        @click="leftDrawerOpen = !leftDrawerOpen"
        />

        <q-toolbar-title>{{ subject.label }}</q-toolbar-title>

        <q-btn-group>
          <q-btn color="amber" text-color="black" glossy icon="$menuLeft" @click="prevDate" />
          <q-btn color="amber" text-color="black" glossy ripple icon="$event" :label="date">
            <q-popup-proxy
              cover
              transition-show="scale"
              transition-hide="scale">
              <q-date :model-value="date" @update:model-value="saveDate" today-btn mask="YYYY-MM-DD" v-close-popup />
            </q-popup-proxy>
          </q-btn>
          <q-btn color="amber" text-color="black" glossy icon="$menuRight" @click="nextDate" />
        </q-btn-group>

    </q-toolbar>
    <q-tabs
      align="justify"
      outside-arrows
      indicator-color="red"
      color="yellow"
      active-color="red"
      active-class="active"
      switch-indicator
      shrink
      stretch
      inline-label
      no-caps
      class="bg-info text-black"
      >
      <q-route-tab
        v-for="item in cats"
        :key="item"
        :name="item"
        :label="item"
        :href="`#${item}`"
        :class="tabClass(item)"
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

  <q-page-container>
    <q-page padding class="q-pt-xl">
      <div>
        <ar-category
          v-for="cat in cats"
          :key="cat"
          :object="catOf(cat)"
          :papers="papers[cat]"
          class="q-ma-md"
          v-intersection="setCur"
          />
      </div>
    </q-page>

  </q-page-container>


</template>

<script>
import ArCategory from '@/Components/ArCategory.vue'

export default {
  components: {
    ArCategory,
  },

  props: {
    subject: Object,
    date: String,
    papers: Object,
  },
  data() {
    return {
      curCat: null,
      leftDrawerOpen: false,
      cats:
      this.$q.localStorage.getItem('cats') ||
      this.subject.categories.map((cat) => cat.value),
    }
  },
  computed: {
    categories() {
      return this.subject.categories
    },
  },
  methods: {
    catOf(cat) {
      return this.categories.find((it) => it.value === cat)
    },
    setCur(entry) {
      if (entry.isIntersecting) {
        this.curCat = entry.target.id
      }
      return true
    },
    tabClass(cat) {
      return (this.curCat === cat) ? 'q-tab--active' : ''
    },
    saveDate(value, reason, details) {
      this.$inertia.reload({
        preserveScroll: false,
        data: {
          date: value,
        },
        only: ['papers', 'date'],
      })
    },
    prevDate() {
      this.saveDate(`${this.date}-`)
    },
    nextDate() {
      this.saveDate(`${this.date}+`)
    },

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
