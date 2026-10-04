import { afterEach, expect, it } from 'vitest'
import { cleanup, fireEvent, render } from '@testing-library/vue'
import { Quasar } from 'quasar'
import LlmSettingsPage from '@/Pages/users/show.vue'

afterEach(cleanup)

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
  const { getByText, getByRole } = render(LlmSettingsPage, {
    props: {
      llmAvailable: { openai: true, gemini: false },
      llmSettings: { openai: { model: 'gpt-5-mini', thinking_level: 'low' } },
      llmModelOptions: {
        openai: [
          { label: 'Provider default (gpt-4o-mini)', value: '', thinkingLevels: [] },
          { label: 'GPT-5 mini (gpt-5-mini)', value: 'gpt-5-mini', thinkingLevels: ['low', 'medium', 'high'] },
        ],
      },
    },
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
  expect(getByRole('radio', { name: 'OpenAI' }).closest('.text-grey-10')).toBeTruthy()
  expect(getByRole('combobox', { name: 'Model' })).toBeTruthy()
  expect(getByRole('combobox', { name: 'Thinking level' })).toBeTruthy()
})

it('clears unsaved key input when changing providers', () => {
  const context = {
    llmSettings: { gemini: { model: 'gemini-2.5-flash', thinking_level: 'medium' } },
    form: { user: {
      llm_provider: 'gemini', llm_api_key: 'unsaved', clear_llm_api_key: true,
      llm_model: 'gpt-5-mini', llm_thinking_level: 'low',
    } },
  }

  LlmSettingsPage.watch['form.user.llm_provider'].call(context)

  expect(context.form.user.llm_api_key).toBe('')
  expect(context.form.user.clear_llm_api_key).toBe(false)
  expect(context.form.user.llm_model).toBe('gemini-2.5-flash')
  expect(context.form.user.llm_thinking_level).toBe('medium')
})

it('shows only the thinking levels supported by the selected model', () => {
  const context = {
    llmModelOptions: {
      openai: [
        { label: 'Provider default', value: '', thinkingLevels: [] },
        { label: 'GPT-4o mini', value: 'gpt-4o-mini', thinkingLevels: [] },
        { label: 'GPT-5 mini', value: 'gpt-5-mini', thinkingLevels: ['minimal', 'low', 'medium', 'high'] },
      ],
    },
    form: { user: { llm_provider: 'openai', llm_model: 'gpt-5-mini', llm_thinking_level: 'low' } },
  }
  context.registryOptions = LlmSettingsPage.computed.registryOptions.call(context)
  context.modelOptions = LlmSettingsPage.computed.modelOptions.call(context)
  context.thinkingOptions = LlmSettingsPage.computed.thinkingOptions.call(context)
  expect(context.thinkingOptions.map(option => option.value)).toEqual(['', 'minimal', 'low', 'medium', 'high'])

  context.form.user.llm_model = 'gpt-4o-mini'
  context.thinkingOptions = LlmSettingsPage.computed.thinkingOptions.call(context)
  LlmSettingsPage.watch['form.user.llm_model'].call(context)
  expect(context.thinkingOptions.map(option => option.value)).toEqual([''])
  expect(context.form.user.llm_thinking_level).toBe('')
})

it('filters the model menu using the model ID', () => {
  const context = {
    modelOptions: [
      { label: 'Provider default', value: '' },
      { label: 'GPT-5 mini', value: 'gpt-5-mini' },
    ],
    filteredModelOptions: [],
  }

  LlmSettingsPage.methods.filterModels.call(context, 'gpt-5', callback => callback())

  expect(context.filteredModelOptions).toEqual([{ label: 'GPT-5 mini', value: 'gpt-5-mini' }])
})

it('keeps a saved model and thinking choice visible if the registry no longer lists it', () => {
  const context = {
    llmSettings: { openai: { model: 'older-model', thinking_level: 'high' } },
    registryOptions: [{ label: 'Provider default', value: '', thinkingLevels: [] }],
    form: { user: { llm_provider: 'openai', llm_model: 'older-model' } },
  }

  expect(LlmSettingsPage.computed.modelOptions.call(context)[0]).toMatchObject({
    value: 'older-model', thinkingLevels: ['high'],
  })
})

it('enables model-specific thinking choices after a model is selected', async () => {
  const user = {
    id: 1, llm_mode: 'personal', llm_provider: 'openai',
    llm_connected_providers: ['openai'],
  }
  const { getByRole, findByText, queryByRole } = render(LlmSettingsPage, {
    props: {
      llmAvailable: { openai: true, gemini: false },
      llmModelOptions: { openai: [
        { label: 'Provider default (gpt-4o-mini)', value: '', thinkingLevels: [] },
        { label: 'GPT-5 mini (gpt-5-mini)', value: 'gpt-5-mini', thinkingLevels: ['low', 'medium', 'high'] },
      ] },
    },
    global: {
      plugins: [Quasar],
      stubs: { QPage: { template: '<div><slot /></div>' } },
      mocks: {
        $page: { props: { auth: { user } } },
        $inertia: { form: data => ({ ...data, errors: {}, hasErrors: false, processing: false }) },
      },
    },
  })

  expect(queryByRole('combobox', { name: 'Thinking level' })).toBeNull()
  await fireEvent.click(getByRole('combobox', { name: 'Model' }))
  await fireEvent.click(await findByText('GPT-5 mini (gpt-5-mini)'))
  expect(getByRole('combobox', { name: 'Thinking level' })).toBeTruthy()
})

it('keeps profile controls readable in the global dark theme', async () => {
  const user = { id: 1, llm_mode: 'personal', llm_provider: 'openai', llm_connected_providers: ['openai'] }
  const { getByRole, getAllByRole, findByRole } = render(LlmSettingsPage, {
    props: {
      llmAvailable: { openai: true, gemini: false },
      llmSettings: { openai: { model: 'gpt-5-mini', thinking_level: 'low' } },
      llmModelOptions: { openai: [
        { label: 'GPT-5 mini (gpt-5-mini)', value: 'gpt-5-mini', thinkingLevels: ['low', 'medium'] },
      ] },
    },
    global: {
      plugins: [[Quasar, { config: { dark: true } }]],
      stubs: { QPage: { template: '<div><slot /></div>' } },
      mocks: {
        $page: { props: { auth: { user } } },
        $inertia: { form: data => ({ ...data, errors: {}, hasErrors: false, processing: false }) },
      },
    },
  })

  const model = getByRole('combobox', { name: 'Model' })
  const thinking = getByRole('combobox', { name: 'Thinking level' })
  const radios = getAllByRole('radio')
  expect(radios).toHaveLength(4)
  radios.forEach(radio => {
    expect(radio.closest('.q-radio').classList.contains('q-radio--dark')).toBe(false)
  })
  const clearKey = getByRole('checkbox', { name: 'Remove my saved key' })
  expect(clearKey.closest('.q-checkbox').classList.contains('q-checkbox--dark')).toBe(false)
  expect(model.closest('.q-field--dark')).toBeNull()
  expect(thinking.closest('.q-field--dark')).toBeNull()
  await fireEvent.click(model)
  const option = await findByRole('option', { name: 'GPT-5 mini (gpt-5-mini)' })
  expect(option.classList.contains('q-item--dark')).toBe(false)
  expect(option.closest('.q-menu').classList.contains('bg-grey-1')).toBe(true)
})
