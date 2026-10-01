<template>
  <q-page padding class="q-pt-xl">
    <div class="row items-center q-gutter-md q-mb-lg">
      <div class="text-h5">
        Recommended papers
      </div>
      <q-btn
        color="primary"
        label="Consider pending papers"
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
      {{ pendingCount }} papers remain to be considered in your followed categories.
      Processing sends papers in batches to {{ providerName(current_user.llm_provider) }} and can be paused and resumed.
      Your bookmarks and followed authors guide the ranking.
    </p>
    <p v-if="!recommendations.length">
      No recommendations yet.
    </p>
    <div class="row">
      <div v-for="item in recommendations" :key="item.id" class="q-pa-md col-12 col-lg-6">
        <p v-if="item.reason" class="text-body1 q-mb-sm">
          {{ providerName(item.provider) }}{{ item.model ? ` (${item.model})` : '' }} · {{ item.score }}/100: {{ item.reason }}
        </p>
        <div v-for="opinion in item.secondOpinions" :key="opinion.provider" class="text-body2 q-mb-sm">
          Single-paper second opinion — {{ providerName(opinion.provider) }} ({{ opinion.model }}) · {{ opinion.score }}/100: {{ opinion.reason }}
        </div>
        <q-btn
          v-for="provider in secondOpinionProviders(item)"
          :key="provider"
          flat
          color="primary"
          :label="`Get ${providerName(provider)} second opinion`"
          :loading="opinionProcessing === `${item.id}:${provider}`"
          @click="secondOpinion(item, provider)"
        />
        <ar-paper :object="item.paper" />
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
  data() { return { refreshing: false, running: false, opinionProcessing: null } },
  computed: {
    canRefresh() {
      return this.availableProviders.includes(this.current_user.llm_provider)
    },
  },
  beforeUnmount() { this.running = false },
  methods: {
    providerName(provider) {
      return provider === 'gemini' ? 'Gemini' : 'OpenAI'
    },
    secondOpinionProviders(item) {
      return this.availableProviders.filter(provider =>
        provider !== item.provider && !item.secondOpinions.some(opinion => opinion.provider === provider))
    },
    secondOpinion(item, provider) {
      this.opinionProcessing = `${item.id}:${provider}`
      this.$inertia.post(`/recommendations/${item.id}/second_opinions`, { provider }, {
        preserveScroll: true,
        onFinish: () => { this.opinionProcessing = null },
      })
    },
    start() {
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
          if (page.props.flash?.alert || !Number.isFinite(page.props.pendingCount) || page.props.pendingCount === 0) {
            this.running = false
          } else if (this.running) {
            this.$nextTick(() => this.processNext())
          }
        },
        onError: () => { this.running = false },
      })
    },
    goToPage(page) {
      this.$inertia.get('/recommendations', { page }, { preserveScroll: false })
    },
  },
}
</script>
