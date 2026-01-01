<template>
  <q-item v-for="paper in papers" :key="paper.id">
    <q-item-section>
      <q-btn no-caps flat :href="$show_path('papers', paper.value)">
        <q-item-label>{{ paper.label }}</q-item-label>
        <q-item-label caption>
          {{ paper.authors.map(it => it.label).join(', ') }}
        </q-item-label>
      </q-btn>
    </q-item-section>
    <q-item-section side>
      <q-btn
        round
        size="sm"
        icon="$close"
        class="bg-secondary text-white"
        @click="removeBookmark(paper, tag)"
      />
    </q-item-section>
  </q-item>
</template>

<script>

export default {
  components: {
  },
  props: {
    papers: {
      type: Array,
    },
    tag: {
      type: String,
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

