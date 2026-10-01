import { expect, it } from 'vitest'
import { render } from '@testing-library/vue'
import { Quasar } from 'quasar'
import LlmSettingsPage from '@/Pages/users/show.vue'

it('shows a saved key only for the selected provider', () => {
  const context = {
    current_user: { llm_connected_providers: ['openai'] },
    form: { user: { llm_provider: 'gemini' } },
  }
  context.savedKeyFor = provider => LlmSettingsPage.methods.savedKeyFor.call(context, provider)

  expect(LlmSettingsPage.computed.keyConfigured.call(context)).toBe(false)
  context.form.user.llm_provider = 'openai'
  expect(LlmSettingsPage.computed.keyConfigured.call(context)).toBe(true)
})

it('marks each provider with its personal-key status', () => {
  const user = {
    id: 1, llm_mode: 'personal', llm_provider: 'openai',
    llm_connected_providers: ['openai'],
  }
  const { getByText } = render(LlmSettingsPage, {
    props: { llmAvailable: { openai: true, gemini: false } },
    global: {
      plugins: [Quasar],
      stubs: { QPage: { template: '<div><slot /></div>' } },
      mocks: {
        $page: { props: { auth: { user } } },
        $inertia: { form: data => ({ ...data, errors: {}, hasErrors: false, processing: false }) },
      },
    },
  })

  expect(getByText('Personal key saved')).toBeTruthy()
  expect(getByText('No personal key')).toBeTruthy()
  expect(getByText('Site connection available')).toBeTruthy()
})

it('clears unsaved key input when changing providers', () => {
  const context = { form: { user: { llm_api_key: 'unsaved', clear_llm_api_key: true } } }

  LlmSettingsPage.watch['form.user.llm_provider'].call(context)

  expect(context.form.user.llm_api_key).toBe('')
  expect(context.form.user.clear_llm_api_key).toBe(false)
})
