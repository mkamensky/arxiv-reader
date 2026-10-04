import { afterEach, expect, it, vi } from 'vitest'
import { cleanup, fireEvent, render, waitFor } from '@testing-library/vue'
import { Quasar } from 'quasar'
import UserCard from '@/Layouts/Components/UserCard.vue'
import RecommendedSidebar from '@/Layouts/Components/RecommendedSidebar.vue'

afterEach(() => {
  cleanup()
  vi.unstubAllGlobals()
})

it('places Recommended in the tag list before user tags', () => {
  const user = {
    id: 1, value: 'reader@example.com', label: 'Reader',
    bpapers: [], fauthors: [], hidden_ids: [],
    tags: [{ id: 2, value: 'reading', label: 'Reading', color: '#234567', papers: [] }],
  }
  const { getByRole } = render(UserCard, {
    global: {
      plugins: [Quasar],
      mocks: {
        $page: { props: { auth: { user } } },
        $show_path: (_resource, id) => `/tags/${id}`,
        $inertia: { form: (_key, data) => ({ ...data, errors: {} }) },
      },
    },
  })

  const recommended = getByRole('link', { name: 'Recommended' })
  const reading = getByRole('link', { name: 'Reading' })
  expect(recommended.getAttribute('href')).toBe('/recommendations')
  expect(recommended.compareDocumentPosition(reading) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy()
})

it('loads recommended papers only when the dropdown opens and can load more', async () => {
  const fetch = vi.fn()
    .mockResolvedValueOnce({ ok: true, json: async () => ({
      papers: [{ id: 1, value: '1234.56789', label: 'First paper', authors: ['Ada'] }],
      nextPage: 2,
    }) })
    .mockResolvedValueOnce({ ok: true, json: async () => ({
      papers: [{ id: 2, value: '1234.56790', label: 'Second paper', authors: ['Bob'] }],
      nextPage: null,
    }) })
  vi.stubGlobal('fetch', fetch)
  const { getByRole, findByText } = render(RecommendedSidebar, { global: { plugins: [Quasar] } })

  expect(fetch).not.toHaveBeenCalled()
  await fireEvent.click(getByRole('button', { name: /expand/i }))
  expect(await findByText('First paper')).toBeTruthy()
  expect(fetch).toHaveBeenCalledWith('/recommendations/sidebar?page=1', expect.any(Object))
  await fireEvent.click(getByRole('button', { name: 'Load more' }))
  expect(await findByText('Second paper')).toBeTruthy()
  await waitFor(() => expect(getByRole('link', { name: 'View all' })).toBeTruthy())
  expect(fetch).toHaveBeenCalledWith('/recommendations/sidebar?page=2', expect.any(Object))
})
