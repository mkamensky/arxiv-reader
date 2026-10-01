import { expect, it, vi } from 'vitest'
import RecommendationsPage from '@/Pages/recommendations/show.vue'

it('continues processing batches until no papers remain', () => {
  const pendingCounts = [2, 0]
  const context = {
    running: true,
    refreshing: false,
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
})

it('stops processing when a batch returns an error', () => {
  const context = {
    running: true,
    refreshing: false,
    $create_path: () => '/recommendations',
    $inertia: {
      post: vi.fn((_path, _data, options) => {
        options.onSuccess({ props: { flash: { alert: 'API key rejected' }, pendingCount: 50 } })
      }),
    },
  }

  RecommendationsPage.methods.processNext.call(context)

  expect(context.$inertia.post).toHaveBeenCalledTimes(1)
  expect(context.running).toBe(false)
})

it('offers a second opinion only from another available provider', () => {
  const context = { availableProviders: ['openai', 'gemini'] }
  const item = { provider: 'openai', secondOpinions: [] }

  expect(RecommendationsPage.methods.secondOpinionProviders.call(context, item)).toEqual(['gemini'])
  item.secondOpinions.push({ provider: 'gemini' })
  expect(RecommendationsPage.methods.secondOpinionProviders.call(context, item)).toEqual([])
})

it('requests an opinion for one selected recommendation', () => {
  const context = {
    opinionProcessing: null,
    $inertia: { post: vi.fn() },
  }

  RecommendationsPage.methods.secondOpinion.call(context, { id: 17 }, 'gemini')

  expect(context.opinionProcessing).toBe('17:gemini')
  expect(context.$inertia.post).toHaveBeenCalledWith(
    '/recommendations/17/second_opinions',
    { provider: 'gemini' },
    expect.objectContaining({ preserveScroll: true }),
  )
})
