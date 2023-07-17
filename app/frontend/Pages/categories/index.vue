<template>
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
    <h2 class="text-h4">{{ category.title }}</h2>
    <ar-paper
      v-for="paper in papers"
      :key="paper.id"
      :object="paper"
      class="q-ma-md"
    />
    <q-inner-loading :showing="loading">
      <q-spinner-hourglass size="50px" />
    </q-inner-loading>
  </div>
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
  },
  data() {
    return {
      tab: this.category?.arxiv,
    }
  },
  computed: {
    loading() {
      return this.tab !== this.category?.arxiv
    },
  },
  methods: {
    setTab(cat) {
      this.tab = cat
      this.$inertia.reload({
        only: ['papers', 'category'],
        data: { id: cat },
      })
    },
  },
}
</script>
