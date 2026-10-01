import { expect, it } from 'vitest'
import { render } from '@testing-library/vue'
import { Quasar } from 'quasar'
import ArPaper from '@/Components/ArPaper.vue'
import paperFactory from './factories/paper'

const paper = paperFactory.build()

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
