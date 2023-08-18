<template>
  <main>
    <h1 class="text-h3">Recent ArXiv submissions</h1>
    <q-tabs
      :model-value="tab"
      align="justify"
      outside-arrows
      indicator-color="red"
      no-caps
      @update:model-value="setTab"
    >
      <q-tab
        v-for="item in categories"
        :key="item.arxiv"
        :name="item.arxiv"
        :label="item.arxiv"
      />
    </q-tabs>
    <div v-if="category" class="relative-position">
      <q-separator />
      <div class="row">
        <h2 class="text-h4">{{ category.title }}</h2>
        <h3 class="text-h5">{{ curDate }}</h3>
      </div>
      <q-scroll-area style="height: 100%">
        <q-infinite-scroll @load="loadMore">
          <ar-paper
            v-for="paper in allPapers"
            :key="paper.id"
            v-scroll-fire="() => updateDate(paper)"
            :object="paper"
            class="q-ma-md"
          />
          <template #loading>
            <div class="row justify-center q-my-md">
              <q-spinner-dots color="primary" size="40px" />
            </div>
          </template>
        </q-infinite-scroll>
      </q-scroll-area>
      <q-inner-loading :showing="loading">
        <q-spinner-hourglass size="50px" />
      </q-inner-loading>
    </div>
    <q-page-sticky position="bottom-left">
      <q-btn color="accent" :label="curDate" />
    </q-page-sticky>
  </main>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'

export default {
  components: {
    ArPaper,
  },

  props: {
    categories: {
      type: Array,
      required: true,
    },
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
      tab: this.category?.arxiv,
      curDate: new Date().toDateString(),
      allPapers: this.papers,
    }
  },
  computed: {
    loading() {
      return this.tab !== this.category?.arxiv
    },
  },
  created() {
    this.initialUrl = this.$page.url
  },
  methods: {
    setTab(cat) {
      this.tab = cat
      this.$inertia.reload({
        preserveState: true,
        only: ['papers', 'category'],
        data: { id: cat },
        onSuccess: () => {
          //window.history.replaceState({}, this.$page.title, this.initialUrl)
        },
      })
    },
    updateDate(paper) {
      this.curDate = new Date(paper.revised)?.toDateString() ?? paper.revised
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
