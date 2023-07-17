<template>
  <h1 class="text-h3">Recent ArXiv submissions</h1>
  <ar-paper
    v-for="paper in papers"
    :key="paper.id"
    :object="paper"
    class="q-ma-md"
  />
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'

export default {
  components: {
    ArPaper,
  },
  props: {
    papers: {
      type: Array,
    },
  },
  data() {
    return {
    }
  },
  computed: {
  },
}
</script>

<style lang="scss" scoped>
</style>

