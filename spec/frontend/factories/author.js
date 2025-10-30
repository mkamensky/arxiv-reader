import { Factory } from 'fishery'
//import { faker } from '@faker-js/faker'

const authorFactory = Factory.define(({seq}) => ({
  id: seq,
  value: 'lebowski_j_1_X',
  label: 'Jeff Lebowski',
}))

export default authorFactory

