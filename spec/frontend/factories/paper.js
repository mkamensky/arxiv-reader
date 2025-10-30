import { Factory } from 'fishery'
import { faker } from '@faker-js/faker'
import authorFactory from './author'

const paperFactory = Factory.define((seq) => ({
  id: seq,
  value: '0123.45678',
  label: faker.book.title(),
  pdf: faker.internet.url(),
  abs: faker.internet.url(),
  authors: authorFactory.buildList(2),
  version: 1,
  journal_ref: faker.book.series(),
  primary: ['12A34', '34B56'],
  secondary: ['56C54'],
  comment: faker.lorem.lines(),
  submitted: faker.date.past(),
  revised: faker.date.past(),
  abstract: faker.lorem.lines(),
}))

export default paperFactory

