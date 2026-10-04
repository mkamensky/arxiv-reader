import { afterEach, expect, it, vi } from 'vitest'
import { cleanup, fireEvent, render } from '@testing-library/vue'
import { Quasar } from 'quasar'
import RecommendationAssessmentButton from '@/Components/RecommendationAssessmentButton.vue'
import geminiIcon from '@/assets/gemini.svg?no-inline'

afterEach(() => {
  cleanup()
  vi.unstubAllGlobals()
})

it('shows the provider icon, score, reason, and saved second opinions', async () => {
  const recommendation = {
    id: 17, provider: 'gemini', model: 'gemini-2.5-flash', score: 82,
    reason: 'Matches your research interests',
    secondOpinions: [{ provider: 'openai', model: 'gpt-5-mini', score: 65, reason: 'Some overlap' }],
  }
  const { getByRole, findByText } = render(RecommendationAssessmentButton, {
    props: { paperId: 1, provider: 'gemini', recommendation, availableProviders: ['gemini', 'openai'] },
    global: { plugins: [Quasar] },
  })

  const button = getByRole('button', { name: 'Gemini assessment' })
  expect(button.querySelector('img')?.getAttribute('src')).toBe(geminiIcon)
  expect(geminiIcon).not.toBe('/gemini.svg')
  expect(button.classList.contains('q-btn--round')).toBe(true)
  expect(button.classList.contains('bg-red-2')).toBe(true)
  await fireEvent.mouseEnter(button)
  expect(await findByText(/Matches your research interests/)).toBeTruthy()
  await fireEvent.click(button)
  expect(await findByText('Some overlap')).toBeTruthy()
})

it('loads an assessment on another page and can request a second opinion', async () => {
  const fetch = vi.fn().mockResolvedValue({ ok: true, json: async () => ({
    recommendation: { id: 17, provider: 'openai', model: 'gpt-5-mini', score: 77,
      reason: 'Related to your bookmarks', secondOpinions: [] },
    availableProviders: ['openai', 'gemini'],
  }) })
  vi.stubGlobal('fetch', fetch)
  const post = vi.fn()
  const { getByRole, findByText } = render(RecommendationAssessmentButton, {
    props: { paperId: 1, provider: 'openai' },
    global: { plugins: [Quasar], mocks: { $inertia: { post } } },
  })

  const button = getByRole('button', { name: 'OpenAI assessment' })
  expect(button.querySelector('.mdi-alpha-o-circle')).toBeTruthy()
  await fireEvent.mouseEnter(button)
  expect(await findByText(/Related to your bookmarks/)).toBeTruthy()
  await fireEvent.click(button)
  await fireEvent.click(await findByText('Get Gemini second opinion'))
  expect(fetch).toHaveBeenCalledTimes(1)
  expect(post).toHaveBeenCalledWith('/recommendations/17/second_opinions',
    { provider: 'gemini' }, expect.objectContaining({ preserveScroll: true }))
  post.mock.calls[0][2].onSuccess()
  expect(fetch).toHaveBeenCalledTimes(2)
})
