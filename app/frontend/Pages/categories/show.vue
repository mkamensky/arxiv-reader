<template>
  <q-page padding class="q-pt-xl">
    <div>
      <ar-paper
        v-for="paper in allPapers"
        :key="paper.id"
        :object="paper"
        class="q-ma-md"
      />
    </div>

    <q-page-sticky expand position="top">
      <q-toolbar class="bg-accent text-white">
        <q-toolbar-title>{{ category.label }}</q-toolbar-title>
        <q-btn icon="$event" color="primary" :label="date?.toDateString()">
          <q-popup-proxy
            cover
            @before-show="updateProxy"
            transition-show="scale"
            transition-hide="scale">
            <q-date v-model="proxyDate" today-btn mask="ddd MMM DD YYYY">
              <div class="row items-center justify-end q-gutter-sm">
                <q-btn label="Cancel" color="primary" flat v-close-popup />
                <q-btn label="OK" color="primary" flat @click="saveDate" v-close-popup />
              </div>
            </q-date>
          </q-popup-proxy>
        </q-btn>
      </q-toolbar>
    </q-page-sticky>
  </q-page>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'
import { date } from 'quasar'

export default {
  components: {
    ArPaper,
  },

  props: {
    category: {
      type: Object,
    },
    papers: {
      type: Array,
    },
  },
  data() {
    return {
      allPapers: this.papers,
      proxyDate: new Date(),
      date: new Date(),
    }
  },
  created() {
    this.initialUrl = this.$page.url
  },
  methods: {
    updateProxy () {
      this.proxyDate = this.date
    },
    saveDate () {
      this.date = new Date(this.proxyDate)
      this.$inertia.reload({
        preserveScroll: false,
        data: {
          date: date.formatDate(this.date, 'YYYY-MM-DD'),
        },
        only: ['papers'],
        onSuccess: () => {
          this.allPapers = this.papers
        },
      })
    },
  },
}
</script>
