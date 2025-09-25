<template>
  <section :id="object.value">
    <h4>
      <q-toolbar class="bg-accent text-white">
        <q-toolbar-title>{{ object.label }}</q-toolbar-title>
      </q-toolbar>
    </h4>

    <div
      v-if="papers?.length"
      class="row"
    >
      <ar-paper
        v-for="paper in papers"
        :key="paper.id"
        :object="paper"
        class="q-pa-md col-12 col-lg-6"
      />
    </div>
    <div v-else>
      Nothing today!
    </div>
  </section>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'

export default {
  components: {
    ArPaper,
  },

  props: {
    object: Object,
    papers: Array,
  },
}
</script>
