<template>
  <q-page padding class="q-pt-xl">
    <div class="row items-center q-gutter-md q-mb-lg">
      <div class="text-h5">
        Recommended papers
      </div>
      <q-btn
        color="primary"
        label="Find recommendations"
        :loading="refreshing"
        :disable="running || !canRefresh || !hasFollowedCategories || pendingCount === 0"
        @click="start"
      />
      <q-btn
        v-if="running"
        color="warning"
        label="Pause after this batch"
        @click="running = false"
      />
      <q-btn flat label="LLM settings" :href="$show_path('users', current_user.id)" />
    </div>
    <p v-if="!canRefresh">
      Connect a {{ providerName(current_user.llm_provider) }} API key or choose an available site connection in your profile to generate recommendations.
    </p>
    <p v-else-if="!hasFollowedCategories">
      Follow at least one category on the recent papers page to get recommendations.
    </p>
    <p v-else>
      {{ pendingCount }} unreviewed papers in your followed categories are eligible.
      This sends them to {{ providerName(current_user.llm_provider) }} in batches. The model selects up to 10 recommendations per batch, each with a relevance score and reason.
      Your bookmarks, followed authors, and explicit thumbs-up or thumbs-down feedback guide its choices; bookmarks are not automatically recommended. Completed batches are remembered, so you can pause and resume later.
      Use the green thumbs-up control on any paper to recommend it yourself. Turning a recommendation off records negative feedback for future reviews.
    </p>
    <div
      v-if="runStartCount !== null"
      class="q-mb-lg"
      role="status"
      aria-live="polite"
    >
      <div class="row justify-between q-mb-xs">
        <span>{{ runStatus }}</span>
        <span>{{ runProcessedCount }} of {{ runStartCount }} papers reviewed this run</span>
      </div>
      <q-linear-progress
        :value="runProgress"
        color="positive"
        track-color="grey-4"
        size="10px"
        aria-label="Paper review progress"
      />
      <div class="text-caption q-mt-xs">
        {{ runRemainingCount }} papers still waiting to be reviewed.
      </div>
      <q-banner v-if="runError" class="bg-negative text-white q-mt-md" role="alert">
        {{ runError }}
      </q-banner>
    </div>
    <p v-if="!recommendations.length">
      No recommendations yet.
    </p>
    <div class="row">
      <div v-for="item in recommendations" :key="item.id" class="q-pa-md col-12 col-lg-6">
        <p v-if="!item.provider" class="text-body1 q-mb-sm">
          Recommended by you
        </p>
        <ar-paper :object="item.paper" :recommendation="item.provider ? item : null" :available-providers="availableProviders" />
      </div>
    </div>
    <div v-if="total > 20" class="row items-center justify-center q-gutter-md q-my-lg">
      <q-btn label="Previous" :disable="page <= 1" @click="goToPage(page - 1)" />
      <span>Page {{ page }} of {{ Math.ceil(total / 20) }}</span>
      <q-btn label="Next" :disable="page * 20 >= total" @click="goToPage(page + 1)" />
    </div>
  </q-page>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'
import userMixin from '@/mixins/userMixin'

export default {
  components: { ArPaper },
  mixins: [userMixin],
  props: {
    recommendations: Array,
    availableProviders: Array,
    hasFollowedCategories: Boolean,
    pendingCount: Number,
    page: Number,
    total: Number,
  },
  data() {
    return {
      refreshing: false,
      running: false,
      runStartCount: null,
      runRemainingCount: null,
      runStoppedWithError: false,
      runError: null,
    }
  },
  computed: {
    canRefresh() {
      return this.availableProviders.includes(this.current_user.llm_provider)
    },
    runProcessedCount() {
      return Math.max(0, this.runStartCount - this.runRemainingCount)
    },
    runProgress() {
      return this.runStartCount > 0 ? Math.min(1, this.runProcessedCount / this.runStartCount) : 0
    },
    runStatus() {
      if (this.runStoppedWithError) return 'Review stopped after an error. You can retry the remaining papers.'
      if (this.refreshing) return this.running ? 'Reviewing a batch...' : 'Finishing the current batch...'
      if (this.runRemainingCount === 0) return 'Review complete.'
      return this.running ? 'Preparing the next batch...' : 'Paused. Resume to review the remaining papers.'
    },
  },
  beforeUnmount() { this.running = false },
  methods: {
    providerName(provider) {
      return provider === 'gemini' ? 'Gemini' : 'OpenAI'
    },
    start() {
      this.runStartCount = this.pendingCount
      this.runRemainingCount = this.pendingCount
      this.runStoppedWithError = false
      this.runError = null
      this.running = true
      this.processNext()
    },
    processNext() {
      if (!this.running) return
      this.$inertia.post(this.$create_path('recommendations'), {}, {
        preserveState: true,
        onStart: () => { this.refreshing = true },
        onFinish: () => { this.refreshing = false },
        onSuccess: (page) => {
          const remaining = page.props.pendingCount
          if (Number.isFinite(remaining)) this.runRemainingCount = remaining
          if (page.props.flash?.alert || !Number.isFinite(remaining)) {
            this.runError = page.props.flash?.alert || 'The server did not report how many papers remain. Please try again.'
            this.runStoppedWithError = true
            this.running = false
          } else if (remaining === 0) {
            this.running = false
          } else if (this.running) {
            this.$nextTick(() => this.processNext())
          }
        },
        onError: (errors) => {
          this.runError = Object.values(errors || {}).find(message => typeof message === 'string') ||
            'The request failed. Please try again.'
          this.runStoppedWithError = true
          this.running = false
        },
      })
    },
    goToPage(page) {
      this.$inertia.get('/recommendations', { page }, { preserveScroll: false })
    },
  },
}
</script>
