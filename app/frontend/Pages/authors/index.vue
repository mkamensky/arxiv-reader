<template>
  <q-page padding class="q-pt-xl">
    <div v-if="authors?.length" class="row">
      <section v-for="author in authors" :key="author.id">
        <q-toolbar class="bg-info glossy col-12">
          <q-toolbar-title>{{ author.label }}</q-toolbar-title>
          <q-btn
            v-if="current_user"
            :icon="followed(author) ? '$starRemove' : '$starAdd'"
            text-color="white"
            outline
            @click="toggleFollow(author)"
          />
        </q-toolbar>
        <div class="row">
          <ar-paper
            v-for="paper in author.papers"
            :key="paper.id"
            :object="paper"
            class="q-pa-md col-12 col-lg-6"
          />
        </div>
      </section>
    </div>
    <div v-else>
      Nothing Found!
    </div>
  </q-page>
</template>

<script>
import ArPaper from '@/Components/ArPaper.vue'
import userMixin from '@/mixins/userMixin'

export default {
  components: {
    ArPaper,
  },
  mixins: [userMixin],
  props: {
    authors: Array,
  },
  data() {
    return {
    }
  },
  computed: {
  },
}
</script>
