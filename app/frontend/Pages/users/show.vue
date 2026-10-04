<template>
  <q-page padding class="q-pt-xl">
    <q-card class="q-mx-auto bg-grey-1 text-grey-10" style="max-width: 640px">
      <q-card-section>
        <div class="text-h5">
          LLM connection
        </div>
        <p class="q-mt-md">
          The LLM uses your bookmarked papers, followed authors, and explicit thumbs-up or thumbs-down ratings as examples of your interests when ranking other papers from your followed categories. Bookmarks and followed authors are not automatically added to your recommendations. Large categories can require many API requests. Your API keys stay on the server and are never shown after saving.
        </p>
      </q-card-section>
      <q-card-section>
        <q-form class="q-gutter-md" @submit.prevent="save">
          <div>
            <div class="text-subtitle2 q-mb-sm">
              Provider
            </div>
            <div
              v-for="provider in providers"
              :key="provider.value"
              class="row items-center q-gutter-sm q-pa-sm q-mb-sm rounded-borders text-grey-10"
              :class="savedKeyFor(provider.value) ? 'bg-green-1' : 'bg-grey-2'"
            >
              <q-radio
                v-model="form.user.llm_provider"
                :val="provider.value"
                :label="provider.label"
                class="text-grey-10"
              />
              <q-chip
                v-if="savedKeyFor(provider.value)"
                color="positive"
                text-color="white"
                icon="mdi-key"
                label="Personal key saved"
              />
              <q-chip
                v-else
                outline
                color="grey-7"
                icon="mdi-key-remove"
                label="No personal key"
              />
              <q-chip
                v-if="llmAvailable[provider.value]"
                outline
                color="info"
                icon="mdi-cloud-check"
                label="Site connection available"
              />
            </div>
          </div>
          <q-option-group
            v-model="form.user.llm_mode"
            type="radio"
            class="text-grey-10"
            :options="[
              { label: 'Use anonymously through this site', value: 'anonymous' },
              { label: `Use my ${providerName} API key`, value: 'personal' },
            ]"
          />
          <p v-if="form.user.llm_mode === 'anonymous' && !llmAvailable[form.user.llm_provider]" class="text-warning">
            The site's {{ providerName }} connection is not configured. Select personal mode and add your own key to use this provider.
          </p>
          <q-input
            v-model="form.user.llm_api_key"
            :dark="false"
            type="password"
            autocomplete="off"
            :label="`${providerName} API key`"
            :hint="keyConfigured ? 'A key is saved for this provider; leave blank to keep it.' : 'Enter a key for this provider.'"
            :error="!!form.errors.llm_api_key"
            :error-message="form.errors.llm_api_key"
          />
          <q-checkbox
            v-if="keyConfigured"
            v-model="form.user.clear_llm_api_key"
            label="Remove my saved key"
          />
          <template v-if="form.user.llm_mode === 'personal' && (keyConfigured || form.user.llm_api_key)">
            <q-select
              v-model="form.user.llm_model"
              :dark="false"
              :options-dark="false"
              popup-content-class="bg-grey-1 text-grey-10"
              :options="filteredModelOptions"
              use-input
              input-debounce="0"
              emit-value
              map-options
              label="Model"
              hint="Search RubyLLM's structured-output models; the provider default is listed first."
              :error="!!form.errors.llm_model"
              :error-message="form.errors.llm_model"
              @filter="filterModels"
            />
            <p v-if="!registryOptions.length" class="text-negative">
              The local model registry could not be loaded. Check the server configuration.
            </p>
            <q-select
              v-model="form.user.llm_thinking_level"
              :dark="false"
              :options-dark="false"
              popup-content-class="bg-grey-1 text-grey-10"
              :options="thinkingOptions"
              emit-value
              map-options
              label="Thinking level"
              :disable="thinkingOptions.length === 1"
              hint="Options depend on the selected model. Model default sends no thinking setting."
              :error="!!form.errors.llm_thinking_level"
              :error-message="form.errors.llm_thinking_level"
            />
          </template>
          <div v-if="form.hasErrors" class="text-negative">
            {{ Object.values(form.errors).join(', ') }}
          </div>
          <q-btn
            type="submit"
            color="primary"
            label="Save connection"
            :loading="form.processing"
          />
          <q-btn
            flat
            color="secondary"
            label="View recommendations"
            href="/recommendations"
          />
        </q-form>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script>
import userMixin from '@/mixins/userMixin'

export default {
  mixins: [userMixin],
  props: { llmAvailable: Object, llmSettings: Object, llmModelOptions: Object },
  data() {
    const provider = this.$page.props.auth.user.llm_provider
    return {
      providers: [
        { label: 'OpenAI', value: 'openai' },
        { label: 'Gemini', value: 'gemini' },
      ],
      filteredModelOptions: this.llmModelOptions?.[provider] || [],
      form: this.$inertia.form({ user: {
        llm_mode: this.$page.props.auth.user.llm_mode,
        llm_provider: provider,
        llm_api_key: '',
        clear_llm_api_key: false,
        llm_model: this.llmSettings?.[provider]?.model || '',
        llm_thinking_level: this.llmSettings?.[provider]?.thinking_level || '',
      } }),
    }
  },
  computed: {
    providerName() {
      return this.form.user.llm_provider === 'gemini' ? 'Gemini' : 'OpenAI'
    },
    keyConfigured() {
      return this.savedKeyFor(this.form.user.llm_provider)
    },
    registryOptions() {
      return this.llmModelOptions?.[this.form.user.llm_provider] || []
    },
    modelOptions() {
      const options = this.registryOptions
      const saved = this.form.user.llm_model
      if (saved && !options.some(option => option.value === saved)) {
        const savedLevel = this.llmSettings?.[this.form.user.llm_provider]?.thinking_level
        return [{
          label: `Saved model (${saved})`, value: saved,
          thinkingLevels: savedLevel ? [savedLevel] : [],
        }, ...options]
      }
      return options
    },
    thinkingOptions() {
      const selected = this.modelOptions.find(option => option.value === this.form.user.llm_model)
      return [
        { label: 'Model default', value: '' },
        ...(selected?.thinkingLevels || []).map(level => ({ label: level, value: level })),
      ]
    },
  },
  watch: {
    'form.user.llm_provider'() {
      this.form.user.llm_api_key = ''
      this.form.user.clear_llm_api_key = false
      this.form.user.llm_model = this.llmSettings?.[this.form.user.llm_provider]?.model || ''
      this.form.user.llm_thinking_level = this.llmSettings?.[this.form.user.llm_provider]?.thinking_level || ''
      this.filteredModelOptions = this.modelOptions
    },
    'form.user.llm_model'() {
      const selected = this.form.user.llm_thinking_level
      if (selected && !this.thinkingOptions.some(option => option.value === selected)) {
        this.form.user.llm_thinking_level = ''
      }
      this.filteredModelOptions = this.modelOptions
    },
  },
  methods: {
    savedKeyFor(provider) {
      return this.current_user.llm_connected_providers?.includes(provider) || false
    },
    filterModels(value, update) {
      update(() => {
        const term = value.toLowerCase()
        this.filteredModelOptions = this.modelOptions.filter(option =>
          option.label.toLowerCase().includes(term) || option.value?.toLowerCase().includes(term))
      })
    },
    save() {
      this.form.patch(this.$update_path('users', this.current_user.id), {
        preserveScroll: true,
        onSuccess: () => {
          this.form.user.llm_api_key = ''
          this.form.user.clear_llm_api_key = false
        },
      })
    },
  },
}
</script>
