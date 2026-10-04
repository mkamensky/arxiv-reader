import { afterEach, expect, it, vi } from 'vitest'
import { cleanup, fireEvent, render } from '@testing-library/vue'
import { Quasar } from 'quasar'
import ArPaper from '@/Components/ArPaper.vue'
import paperFactory from './factories/paper'

const paper = paperFactory.build()

afterEach(cleanup)

it('renders the paper title', () => {
  const { getByRole } = render(ArPaper, {
    props: {
      object: paper,
    },
    global: {
      plugins: [Quasar],
      mocks: {
        $page: { props: {} },
        $show_path: (_resource, id) => `/papers/${id}`,
        $mdi: text => text,
        $md: text => text,
      },
    },
  })
  const el = getByRole('heading')
  expect(el.textContent).toContain(paper.label)
})

it('renders the recommended control for a signed-in user and sends positive feedback', async () => {
  const post = vi.fn()
  const user = {
    bpapers: [], fauthors: [], tags: [], hidden_ids: [], recommended_ids: [],
  }
  const { getByTitle } = render(ArPaper, {
    props: { object: paper },
    global: {
      plugins: [Quasar],
      mocks: {
        $page: { props: { auth: { user } } },
        $show_path: (_resource, id) => `/papers/${id}`,
        $mdi: text => text,
        $md: text => text,
        $inertia: { post },
      },
    },
  })

  await fireEvent.click(getByTitle('Recommend this paper and teach the model your preference'))

  expect(post).toHaveBeenCalledWith(
    `/papers/${paper.id}/recommendation_feedback`,
    { sentiment: 'positive' },
    expect.objectContaining({ preserveScroll: true }),
  )
})

it('keeps the bookmark in the title group and shows assessment with bottom controls', () => {
  const scoredPaper = { ...paper, id: 1 }
  const user = {
    bpapers: [], fauthors: [], tags: [], hidden_ids: [], recommended_ids: [scoredPaper.id],
    recommendation_providers: { [scoredPaper.id]: 'gemini' },
  }
  const { getByRole, getByTitle } = render(ArPaper, {
    props: { object: scoredPaper },
    global: {
      plugins: [Quasar],
      mocks: {
        $page: { props: { auth: { user } } },
        $show_path: (_resource, id) => `/papers/${id}`,
        $mdi: text => text, $md: text => text,
      },
    },
  })

  const heading = getByRole('heading')
  const icon = getByRole('button', { name: 'Gemini assessment' })
  expect(heading.classList.contains('q-btn-group')).toBe(true)
  expect(heading.contains(getByTitle('Bookmark'))).toBe(true)
  expect(heading.contains(icon)).toBe(false)
  expect(icon.closest('.q-list')).toBe(getByTitle('Toggle abstract').closest('.q-list'))
})
