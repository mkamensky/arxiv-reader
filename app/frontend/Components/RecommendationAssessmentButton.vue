<template>
  <q-btn
    dense
    flat
    round
    class="bg-red-2 text-black"
    :icon="assessmentIcon"
    :aria-label="`${providerName(provider)} assessment`"
    :title="`${providerName(provider)} assessment`"
    @mouseenter="loadAssessment"
    @focus="loadAssessment"
    @click="loadAssessment"
  >
    <q-tooltip class="text-body2" max-width="360px">
      <template v-if="assessment">
        {{ providerName(assessment.provider) }} · {{ assessment.score }}/100<br>
        {{ assessment.reason || 'No reason was recorded.' }}
      </template>
      <template v-else>
        {{ loading ? 'Loading assessment...' : error || 'Open assessment' }}
      </template>
    </q-tooltip>
    <q-popup-proxy>
      <q-card class="bg-grey-1 text-dark" style="width: 420px; max-width: 90vw">
        <q-card-section class="text-h6">
          LLM assessment
        </q-card-section>
        <q-card-section v-if="loading">
          Loading assessment...
        </q-card-section>
        <q-card-section v-else-if="error" class="text-negative">
          {{ error }}
          <q-btn flat label="Retry" @click.stop="loadAssessment" />
        </q-card-section>
        <template v-else-if="assessment">
          <q-card-section>
            <div class="text-subtitle2">
              {{ providerName(assessment.provider) }}{{ assessment.model ? ` (${assessment.model})` : '' }} · {{ assessment.score }}/100
            </div>
            <p class="q-mt-sm q-mb-none">
              {{ assessment.reason || 'No reason was recorded.' }}
            </p>
          </q-card-section>
          <q-separator v-if="assessment.secondOpinions.length" />
          <q-card-section v-for="opinion in assessment.secondOpinions" :key="opinion.provider">
            <div class="text-subtitle2">
              Second opinion — {{ providerName(opinion.provider) }} ({{ opinion.model }}) · {{ opinion.score }}/100
            </div>
            <p class="q-mt-sm q-mb-none">
              {{ opinion.reason }}
            </p>
          </q-card-section>
          <q-card-actions v-if="secondOpinionProviders.length">
            <q-btn
              v-for="otherProvider in secondOpinionProviders"
              :key="otherProvider"
              flat
              color="primary"
              :label="`Get ${providerName(otherProvider)} second opinion`"
              :loading="opinionProcessing === otherProvider"
              @click.stop="secondOpinion(otherProvider)"
            />
          </q-card-actions>
        </template>
      </q-card>
    </q-popup-proxy>
  </q-btn>
</template>

<script>
import geminiIcon from '@/assets/gemini.svg?no-inline'

export default {
  props: {
    paperId: { type: Number, required: true },
    provider: { type: String, required: true },
    recommendation: { type: Object, default: null },
    availableProviders: { type: Array, default: null },
  },
  data() {
    return { loadedAssessment: null, loadedProviders: [], loading: false, error: null, opinionProcessing: null }
  },
  computed: {
    assessmentIcon() {
      return this.provider === 'gemini' ? `img:${geminiIcon}` : 'mdi-alpha-o-circle'
    },
    assessment() {
      return this.recommendation || this.loadedAssessment
    },
    secondOpinionProviders() {
      if (!this.assessment) return []
      return (this.availableProviders || this.loadedProviders).filter(provider =>
        provider !== this.assessment.provider &&
        !this.assessment.secondOpinions.some(opinion => opinion.provider === provider))
    },
  },
  methods: {
    providerName(provider) {
      return provider === 'gemini' ? 'Gemini' : 'OpenAI'
    },
    async loadAssessment() {
      if (this.assessment || this.loading) return
      this.loading = true
      this.error = null
      try {
        const response = await fetch(`/papers/${this.paperId}/recommendation_assessment`, {
          credentials: 'same-origin',
          headers: { Accept: 'application/json' },
        })
        if (!response.ok) throw new Error(`Request failed (${response.status})`)
        const result = await response.json()
        this.loadedAssessment = result.recommendation
        this.loadedProviders = result.availableProviders
      } catch (error) {
        this.error = `Could not load assessment: ${error.message}`
      } finally {
        this.loading = false
      }
    },
    secondOpinion(provider) {
      this.opinionProcessing = provider
      this.$inertia.post(`/recommendations/${this.assessment.id}/second_opinions`, { provider }, {
        preserveScroll: true,
        onSuccess: () => {
          if (!this.recommendation) {
            this.loadedAssessment = null
            this.loadAssessment()
          }
        },
        onFinish: () => { this.opinionProcessing = null },
      })
    },
  },
}
</script>
