<template>
  <q-page padding class="q-pt-xl" >
    <div v-if="papers?.length" class="row">
      <ar-paper
        v-for="paper in papers"
        :key="paper.id"
        :object="paper"
        class="q-pa-md col-12 col-lg-6"
        />
    </div>
    <div v-else>
      Nothing yet!
    </div>
  </q-page>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'

export default {
  components: {
    ArPaper,
  },

  props: {
    author: Object,
  },
  data() {
    return {
    }
  },
  computed: {
    papers() {
      return this.author.papers
    },
  },
}
</script>
