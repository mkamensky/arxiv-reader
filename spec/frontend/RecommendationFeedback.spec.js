import { expect, it, vi } from 'vitest'
import userMixin from '@/mixins/userMixin'

it('shows a virtual recommended control without adding a real user tag', () => {
  const paper = { id: 7 }
  const context = {
    user: { tags: [] },
    current_user: { recommended_ids: [7] },
    recommended_ids: new Set([7]),
    bookmarked: () => false,
  }

  const tags = userMixin.methods.tagsOf.call(context, paper)

  expect(tags).toHaveLength(2)
  expect(tags[0]).toMatchObject({ recommendation: true, icon: 'mdi-thumb-up' })
  expect(tags[0].tip).toContain('not a good match')
})

it('sends negative feedback for turning off a recommendation and positive feedback for turning it on', () => {
  const paper = { id: 7 }
  const context = {
    recommended_ids: new Set([7]),
    $inertia: { post: vi.fn() },
  }

  userMixin.methods.toggleRecommendation.call(context, paper)
  expect(context.$inertia.post).toHaveBeenCalledWith(
    '/papers/7/recommendation_feedback', { sentiment: 'negative' },
    expect.objectContaining({ preserveScroll: true }),
  )

  context.recommended_ids.delete(7)
  userMixin.methods.toggleRecommendation.call(context, paper)
  expect(context.$inertia.post).toHaveBeenLastCalledWith(
    '/papers/7/recommendation_feedback', { sentiment: 'positive' },
    expect.objectContaining({ preserveScroll: true }),
  )
})
