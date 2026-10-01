import { expect, it } from 'vitest'
import LlmSettingsPage from '@/Pages/users/show.vue'

it('shows a saved key only for the selected provider', () => {
  const context = {
    current_user: { llm_connected_providers: ['openai'] },
    form: { user: { llm_provider: 'gemini' } },
  }

  expect(LlmSettingsPage.computed.keyConfigured.call(context)).toBe(false)
  context.form.user.llm_provider = 'openai'
  expect(LlmSettingsPage.computed.keyConfigured.call(context)).toBe(true)
})

it('clears unsaved key input when changing providers', () => {
  const context = { form: { user: { llm_api_key: 'unsaved', clear_llm_api_key: true } } }

  LlmSettingsPage.watch['form.user.llm_provider'].call(context)

  expect(context.form.user.llm_api_key).toBe('')
  expect(context.form.user.clear_llm_api_key).toBe(false)
})
