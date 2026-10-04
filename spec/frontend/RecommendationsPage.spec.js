import { expect, it, vi } from 'vitest'
import { fireEvent, render } from '@testing-library/vue'
import { Quasar } from 'quasar'
import RecommendationsPage from '@/Pages/recommendations/show.vue'
import paperFactory from './factories/paper'

it('continues processing batches until no papers remain', () => {
  const pendingCounts = [2, 0]
  const context = {
    running: true,
    refreshing: false,
    runStartCount: 82,
    runRemainingCount: 82,
    runStoppedWithError: false,
    $create_path: () => '/recommendations',
    $nextTick: callback => callback(),
    $inertia: {
      post: vi.fn((_path, _data, options) => {
        options.onStart()
        options.onSuccess({ props: { flash: {}, pendingCount: pendingCounts.shift() } })
        options.onFinish()
      }),
    },
  }
  context.processNext = () => RecommendationsPage.methods.processNext.call(context)

  context.processNext()

  expect(context.$inertia.post).toHaveBeenCalledTimes(2)
  expect(context.running).toBe(false)
  expect(context.refreshing).toBe(false)
  expect(context.runRemainingCount).toBe(0)
  expect(RecommendationsPage.computed.runProcessedCount.call(context)).toBe(82)
  context.runProcessedCount = 82
  expect(RecommendationsPage.computed.runProgress.call(context)).toBe(1)
  expect(RecommendationsPage.computed.runStatus.call(context)).toBe('Review complete.')
})

it('stops processing when a batch returns an error', () => {
  const detail = 'Gemini reached the 8192-token output limit. Finish reason: max_tokens. ' +
    'Token usage: input 12000, output 8192, thinking 6700 (included in output). No results from this request were saved.'
  const context = {
    running: true,
    refreshing: false,
    $create_path: () => '/recommendations',
    $inertia: {
      post: vi.fn((_path, _data, options) => {
        options.onSuccess({ props: { flash: { alert: detail }, pendingCount: 50 } })
      }),
    },
  }

  RecommendationsPage.methods.processNext.call(context)

  expect(context.$inertia.post).toHaveBeenCalledTimes(1)
  expect(context.running).toBe(false)
  expect(context.runStoppedWithError).toBe(true)
  expect(context.runError).toBe(detail)
})

it('starts a new run from the current pending count', () => {
  const context = { pendingCount: 120, running: false, runStoppedWithError: true, runError: 'Old error', processNext: vi.fn() }

  RecommendationsPage.methods.start.call(context)

  expect(context.runStartCount).toBe(120)
  expect(context.runRemainingCount).toBe(120)
  expect(context.runStoppedWithError).toBe(false)
  expect(context.runError).toBe(null)
  expect(context.running).toBe(true)
  expect(context.processNext).toHaveBeenCalledOnce()
})

it('shows validation errors from a failed batch request', () => {
  const context = {
    running: true,
    $create_path: () => '/recommendations',
    $inertia: {
      post: vi.fn((_path, _data, options) => {
        options.onError({ base: 'The connection is unavailable.' })
      }),
    },
  }

  RecommendationsPage.methods.processNext.call(context)

  expect(context.running).toBe(false)
  expect(context.runError).toBe('The connection is unavailable.')
})

it('reports partial progress when paused after a batch', () => {
  const context = {
    running: true,
    refreshing: false,
    runStartCount: 100,
    runRemainingCount: 100,
    runStoppedWithError: false,
    $create_path: () => '/recommendations',
    $inertia: {
      post: vi.fn((_path, _data, options) => {
        options.onStart()
        context.running = false
        options.onSuccess({ props: { flash: {}, pendingCount: 20 } })
        options.onFinish()
      }),
    },
  }

  RecommendationsPage.methods.processNext.call(context)

  expect(context.$inertia.post).toHaveBeenCalledOnce()
  expect(context.runRemainingCount).toBe(20)
  expect(RecommendationsPage.computed.runProcessedCount.call(context)).toBe(80)
  expect(RecommendationsPage.computed.runStatus.call(context)).toContain('Paused')
})

it('shows a saved assessment icon in the recommendation card bottom row', async () => {
  const user = {
    id: 1, llm_provider: 'openai', bpapers: [], fauthors: [], tags: [], hidden_ids: [],
    recommended_ids: [1], recommendation_providers: { 1: 'openai' },
  }
  const item = {
    id: 17, provider: 'openai', model: 'gpt-5-mini', score: 82,
    reason: 'Matches your research interests',
    secondOpinions: [{ provider: 'gemini', model: 'gemini-2.5-flash', score: 65, reason: 'Some overlap' }],
    paper: { ...paperFactory.build(), id: 1 },
  }
  const { getByRole, findByText, queryByRole } = render(RecommendationsPage, {
    props: {
      recommendations: [item], availableProviders: ['openai', 'gemini'],
      hasFollowedCategories: true, pendingCount: 0, page: 1, total: 1,
    },
    global: {
      plugins: [Quasar],
      stubs: { QPage: { template: '<div><slot /></div>' } },
      mocks: {
        $page: { props: { auth: { user } } },
        $show_path: (resource, id) => `/${resource}/${id}`,
        $mdi: text => text,
        $md: text => text,
      },
    },
  })

  expect(queryByRole('button', { name: 'LLM assessment' })).toBeNull()
  const button = getByRole('button', { name: 'OpenAI assessment' })
  expect(getByRole('heading').contains(button)).toBe(false)
  expect(button.closest('.q-list')).toBeTruthy()
  await fireEvent.mouseEnter(button)
  expect(await findByText(/Matches your research interests/)).toBeTruthy()
})
