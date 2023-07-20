<template>
  <q-page padding class="q-pt-xl">
    <q-infinite-scroll @load="loadMore">
      <ar-paper
        v-for="paper in allPapers"
        :key="paper.id"
        v-intersection="
          (entry) => {
            if (entry.isIntersecting) curDate = paperDate(paper)
          }
        "
        :object="paper"
        class="q-ma-md"
      />
    </q-infinite-scroll>
    <q-page-sticky expand position="top">
      <q-toolbar class="bg-accent text-white">
        <q-toolbar-title>{{ category.label }}</q-toolbar-title>
        <q-btn outline :label="curDate" />
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
    nextPage: {
      type: Number,
    },
  },
  data() {
    return {
      curDate: this.paperDate(this.papers[0]),
      allPapers: this.papers,
    }
  },
  created() {
    this.initialUrl = this.$page.url
  },
  methods: {
    paperDate(paper) {
      return new Date(paper.revised)?.toDateString() ?? paper.revised
    },
    loadMore(index, done) {
      if (this.nextPage === null) {
        done()
        return
      }

      this.$inertia.reload({
        preserveState: true,
        preserveScroll: true,
        only: ['papers', 'nextPage'],
        data: { page: this.nextPage },
        onSuccess: () => {
          this.allPapers = [...this.allPapers, ...this.papers]
          window.history.replaceState({}, this.$page.title, this.initialUrl)
          done()
        },
      })
    },
  },
}
</script>
