<template>
  <q-page padding class="q-pt-xl">
    <div v-if="papers?.length" class="row">
      <ar-paper
        v-for="index in papers.length - 1"
        :key="papers[index-1].id"
        :object="papers[index-1]"
        class="q-pa-md col-12 col-lg-6"
      />
      <when-visible v-if="cursor" :params="visParams" always>
        <template #fallback>
          <q-spinner-hourglass color="primary" size="2em">
            <q-tooltip :offset="[0, 8]">
              Loading...
            </q-tooltip>
          </q-spinner-hourglass>
        </template>
        <q-tooltip :offset="[8, 8]">
          {{ papers.length }}/{{ total }}
        </q-tooltip>
        <ar-paper
          :object="papers[papers.length-1]"
          class="q-pa-md col-12 col-lg-6"
        />
      </when-visible>
      <ar-paper
        v-else
        :object="papers[papers.length-1]"
        class="q-pa-md col-12 col-lg-6"
      />
    </div>
    <div v-else>
      Nothing yet!
    </div>
  </q-page>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'
import { WhenVisible } from '@inertiajs/vue3'

export default {
  components: {
    ArPaper,
    WhenVisible,
  },

  props: {
    papers: Array,
    cursor: Number,
    total: Number,
  },
  data() {
    return {
    }
  },
  computed: {
    visParams() {
      return {
        data: {
          cursor: this.cursor
        },
        only: ['papers', 'cursor'],
        preserveUrl: true,
      }
    },
  },
}
</script>
