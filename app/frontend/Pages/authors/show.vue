<template>
  <q-header elevated class="bg-primary text-white" height-hint="98">
    <q-toolbar>
      <q-toolbar-title>{{ author.label }}</q-toolbar-title>
    </q-toolbar>
  </q-header>

  <q-page-container>
    <q-page padding class="q-pt-xl">
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
  </q-page-container>

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
