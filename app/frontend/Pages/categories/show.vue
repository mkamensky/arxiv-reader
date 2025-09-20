<template>
  <q-page padding class="q-pt-xl">
    <div>
      <ar-paper
        v-for="paper in papers"
        :key="paper.id"
        :object="paper"
        class="q-ma-md"
      />
    </div>

    <q-page-sticky expand position="top">
      <q-toolbar class="bg-accent text-white">
        <q-toolbar-title>{{ category.label }}</q-toolbar-title>
        <q-btn icon="$event" color="primary" :label="date">
          <q-popup-proxy
            cover
            transition-show="scale"
            transition-hide="scale">
            <q-date :model-value="date" @update:model-value="saveDate" today-btn mask="YYYY-MM-DD" v-close-popup />
          </q-popup-proxy>
        </q-btn>
      </q-toolbar>
    </q-page-sticky>
  </q-page>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'

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
    date: {
      type: String,
    },
  },
  data() {
    return {
    }
  },
  methods: {
    saveDate (value, reason, details) {
      this.$inertia.reload({
        preserveScroll: false,
        data: {
          date: value,
        },
        only: ['papers', 'date'],
      })
    },
  },
}
</script>
