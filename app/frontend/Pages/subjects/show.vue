<template>
  <q-page padding class="q-pt-md">
    <div>
      <ar-category
        v-for="cat in cats"
        :key="cat"
        v-intersection="setCur"
        :object="catMap[cat]"
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
          <q-toolbar-title>
            <q-btn-dropdown split color="secondary" :label="subject.label">
              <q-list>
                <q-item
                  v-for="sub in subjects"
                  :key="sub.value"
                  v-close-popup
                  :href="$show_path('subjects', sub.value)"
                  clickable
                >
                  <q-item-section>
                    <q-item-label>{{ sub.label }}</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-btn-dropdown>
          </q-toolbar-title>
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
          :options="allCategories"
          type="toggle"
          class="scroll overflow-auto"
          style="max-height: 80vh"
        />
      </div>
    </q-drawer>
    <q-page-sticky
      expand
      position="top"
      class="q-pt-xs"
      style="max-width: 100vw"
    >
      <q-toolbar class="bg-secondary justify-around">
        <q-btn-group>
          <q-btn
            color="warning"
            text-color="black"
            glossy
            icon="$menuLeft"
            :disabled="date <= first"
            @click="prevDate"
          />
          <q-btn
            color="warning"
            text-color="black"
            glossy
            ripple
            icon="$event"
            :label="date"
          >
            <q-popup-proxy
              ref="dateComp"
              cover
              transition-show="scale"
              transition-hide="scale"
            >
              <q-date
                :model-value="date"
                today-btn
                mask="YYYY-MM-DD"
                :options="dateOptions"
                @update:model-value="saveDate"
              />
            </q-popup-proxy>
          </q-btn>
          <q-btn
            color="warning"
            text-color="black"
            glossy
            ripple
            icon="$menuRight"
            :disabled="date >= last"
            @click="nextDate"
          />
        </q-btn-group>

        <q-toolbar-title v-if="$q.screen.gt.xs">
          <q-tabs
            dense
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
            class="bg-info text-black justify-evenly q-ma-sm"
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
          glossy
          ripple
          color="warning"
          text-color="black"
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
import userMixin from '@/mixins/userMixin'

export default {
  components: {
    ArCategory,
  },
  mixins: [userMixin],

  props: {
    subject: Object,
    date: String,
    papers: Object,
    subjects: Array,
    last: String,
    first: String,
  },
  data() {
    return {
      curCat: null,
      drawerOpen: false,
      cats: this.current_user?.categories?.map(cat => cat.value) ||
            this.$q.localStorage.getItem('cats') ||
            this.subject.categories.map((cat) => cat.value)
    }
  },
  computed: {
    allCategories() {
      return this.subject.categories
    },
    categories() {
      return new Set(this.current_user?.categories?.map(it => it.id) || [])
    },
    catMap() {
      return this.allCategories
        .reduce((res, cur) => ({...res, [cur.value]: cur}), {})
    },
    fst() {
      return this.first.replaceAll('-', '/')
    },
    lst() {
      return this.last.replaceAll('-', '/')
    },
  },
  watch: {
    cats: {
      handler(val) {
        if (this.current_user) {
          this.current_user.categories =
            this.cats.map(cat => this.catMap[cat])
          this.updateList('categories', 'category_ids')
        } else {
          this.$q.localStorage.set('cats', val)
        }
      },
      immediate: true,
    },
  },
  methods: {
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
      this.$refs.dateComp.hide()
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
    dateOptions(date) {
      return date >= this.fst && date <= this.lst
    },
  },

}
</script>
