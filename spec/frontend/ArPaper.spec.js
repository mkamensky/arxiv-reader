import { expect, it } from 'vitest'
import { render } from '@testing-library/vue'
import ArPaper from '@/Components/ArPaper.vue'
import paperFactory from './factories/paper'

const paper = paperFactory.build()

it('renders the paper title', async () => {
  ArPaper.$page = { props: {foo: 'bar'}}
  const { getByRole } = render(ArPaper, {
    props: {
      object: paper,
    }})
  const el = getByRole('heading')
  await expect.element(el).toHaveTextContent(paper.title)
})

