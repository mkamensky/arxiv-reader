<template>
  <q-page padding class="q-pt-md">
    <div>
      <ar-category
        v-for="cat in cats"
        :key="cat"
        v-intersection="setCur"
        :object="catOf(cat)"
        :papers="papers[cat]"
        class="q-ma-md"
      />
    </div>
    <q-drawer
      v-model="drawerOpen"
      side="right"
      bordered
      column
      class="text-black"
    >
      <div class="q-pa-xs relative-position">
        <q-toolbar glossy class="bg-accent rounded-borders">
          <q-toolbar-title>Categories</q-toolbar-title>
          <q-btn
            icon="$close"
            flat
            round
            dense
            @click="drawerOpen=false"
          />
        </q-toolbar>
        <q-option-group
          v-model="cats"
          :options="categories"
          type="toggle"
          class="scroll overflow-auto"
        />
      </div>
    </q-drawer>
    <q-page-sticky expand position="top" class="q-pt-xs">
      <q-toolbar class="bg-secondary">
        <q-btn-group>
          <q-btn
            color="amber"
            text-color="black"
            glossy
            icon="$menuLeft"
            @click="prevDate"
          />
          <q-btn
            color="amber"
            text-color="black"
            glossy
            ripple
            icon="$event"
            :label="date"
          >
            <q-popup-proxy
              cover
              transition-show="scale"
              transition-hide="scale"
            >
              <q-date
                v-close-popup
                :model-value="date"
                today-btn
                mask="YYYY-MM-DD"
                @update:model-value="saveDate"
              />
            </q-popup-proxy>
          </q-btn>
          <q-btn
            color="amber"
            text-color="black"
            glossy
            icon="$menuRight"
            @click="nextDate"
          />
        </q-btn-group>

        <q-toolbar-title>
          <q-tabs
            align="justify"
            outside-arrows
            indicator-color="red"
            color="yellow"
            active-color="red"
            active-class="active"
            switch-indicator
            stretch
            inline-label
            no-caps
            class="bg-info text-black justify-evenly"
          >
            <q-route-tab
              v-for="item in cats"
              :key="item"
              :name="item"
              :label="item"
              :href="`#${item}`"
              :class="tabClass(item)"
            >
              <q-badge v-if="papers[item].length > 0" color="red" floating>
                {{ papers[item].length }}
              </q-badge>
            </q-route-tab>
          </q-tabs>
        </q-toolbar-title>

        <q-btn
          dense
          flat
          rounded
          :class="drawerOpen ? 'hidden' : ''"
          icon="$show"
          @click="drawerOpen = true"
        />
      </q-toolbar>
    </q-page-sticky>
  </q-page>
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
      drawerOpen: false,
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
  watch: {
    cats: {
      handler(val) {
        this.$q.localStorage.set('cats', val)
      },
      immediate: true,
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
    saveDate(value) {
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

}
</script>
