<template>
  <q-expansion-item
    v-model="expanded"
    expand-icon-toggle
    expand-separator
    @show="reloadPapers"
  >
    <template #header>
      <q-item-section avatar>
        <q-icon name="mdi-thumb-up" color="positive" />
      </q-item-section>
      <q-item-section>
        <q-btn
          flat
          no-caps
          align="left"
          class="q-px-none text-positive"
          href="/recommendations"
        >
          Recommended
        </q-btn>
      </q-item-section>
    </template>
    <q-item v-if="loading && !papers.length">
      Loading recommended papers...
    </q-item>
    <q-item v-else-if="error" class="text-negative">
      {{ error }}
      <q-btn flat label="Retry" @click="loadPapers" />
    </q-item>
    <q-item v-else-if="!papers.length">
      No recommendations yet.
    </q-item>
    <q-item v-for="paper in papers" :key="paper.id">
      <q-item-section>
        <q-btn
          flat
          no-caps
          align="left"
          :href="`/papers/${paper.value}`"
        >
          <q-item-label>
            {{ paper.label }}
          </q-item-label>
          <q-item-label caption>
            {{ paper.authors.join(', ') }}
          </q-item-label>
        </q-btn>
      </q-item-section>
    </q-item>
    <q-item v-if="nextPage || papers.length">
      <q-item-section class="row">
        <q-btn
          v-if="nextPage"
          flat
          label="Load more"
          :loading="loading"
          @click="loadPapers"
        />
        <q-btn flat label="View all" href="/recommendations" />
      </q-item-section>
    </q-item>
  </q-expansion-item>
</template>

<script>
export default {
  data() {
    return {
      expanded: false,
      papers: [],
      nextPage: 1,
      loading: false,
      error: null,
    }
  },
  methods: {
    reloadPapers() {
      this.papers = []
      this.nextPage = 1
      this.loadPapers()
    },
    async loadPapers() {
      if (!this.nextPage || this.loading) return

      this.loading = true
      this.error = null
      try {
        const response = await fetch(`/recommendations/sidebar?page=${this.nextPage}`, {
          credentials: 'same-origin',
          headers: { Accept: 'application/json' },
        })
        if (!response.ok) throw new Error(`Request failed (${response.status})`)
        const result = await response.json()
        this.papers.push(...result.papers)
        this.nextPage = result.nextPage
      } catch (error) {
        this.error = `Could not load recommendations: ${error.message}`
      } finally {
        this.loading = false
      }
    },
  },
}
</script>
