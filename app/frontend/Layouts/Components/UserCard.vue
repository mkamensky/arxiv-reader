<template>
  <q-card class="q-mb-sm">
    <q-card-section horizontal>
      <q-card-section class="col q-pt-xs">
        <div class="text-overline">
          {{ current_user.value }}
        </div>
        <div class="text-h5 q-mt-sm q-mb-xs">
          {{ current_user.label }}
        </div>
      </q-card-section>
      <q-card-section v-if="current_user?.avatar" class="col-auto flex flex-center">
        <q-avatar size="72px">
          <img :src="current_user.avatar">
        </q-avatar>
      </q-card-section>
    </q-card-section>
    <q-card-actions class="justify-around">
      <q-btn
        color="primary"
        label="Logout"
        push
        size="sm"
        @click="logout"
      />
    </q-card-actions>
  </q-card>

  <q-toolbar class="bg-info text-black">
    <q-toolbar-title>
      Followed authors
    </q-toolbar-title>
  </q-toolbar>
  <q-list style="max-height: 80%" dense class="scroll overflow-auto">
    <q-expansion-item
      v-for="author in current_user.fauthors || []"
      :key="author.value"
      expand-icon-toggle
      expand-separator
      :hide-expand-icon="author_papers(author).length == 0"
    >
      <template #header>
        <q-item-section avatar>
          <q-btn
            round
            size="xs"
            icon="$close"
            class="bg-secondary text-white"
            @click="removeAuthor(author)"
          />
        </q-item-section>
        <q-item-section>
          <q-btn
            ripple
            flat
            align="left"
            color="warning"
            no-caps
            class="q-px-none"
            :href="$show_path('authors', author.value)"
          >
            <q-item-label>{{ author.label }}</q-item-label>
          </q-btn>
        </q-item-section>
      </template>
      <q-item
        v-for="paper in author_papers(author)"
        :key="paper.id"
      >
        <q-item-section>
          <q-btn no-caps flat :href="$show_path('papers', paper.value)">
            <q-item-label>{{ paper.label }}</q-item-label>
            <q-item-label caption>
              {{ paper.authors.map(it => it.label).join(', ') }}
            </q-item-label>
          </q-btn>
        </q-item-section>
        <q-item-section side>
          <q-btn
            round
            size="sm"
            icon="$close"
            class="bg-secondary text-white"
            @click="removeBookmark(paper)"
          />
        </q-item-section>
      </q-item>
    </q-expansion-item>
    <q-expansion-item
      v-if="other_papers.length > 0"
      expand-separator
      label="Other Bookmarked Papers"
      icon="$menu"
      header-class="text-warning"
    >
      <q-item
        v-for="paper in other_papers"
        :key="paper.id"
      >
        <q-item-section>
          <q-btn no-caps flat :href="$show_path('papers', paper.value)">
            <q-item-label>{{ paper.label }}</q-item-label>
            <q-item-label caption>
              {{ paper.authors.map(it => it.label).join(', ') }}
            </q-item-label>
          </q-btn>
        </q-item-section>
        <q-item-section side>
          <q-btn
            round
            size="sm"
            icon="$close"
            class="bg-secondary text-white"
            @click="removeBookmark(paper)"
          />
        </q-item-section>
      </q-item>
    </q-expansion-item>
  </q-list>
</template>

<script>
import userMixin from '@/mixins/userMixin'

export default {
  mixins: [userMixin],
  data() {
    return {
    }
  },
  computed: {
  },
  methods: {
    logout(evt) {
      if (evt) evt.preventDefault()
      this.$inertia.replaceProp('auth', {}, {}) // TODO
      this.$inertia.delete(this.$create_path('sessions'), {
        preserveScroll: true,
        preserveState: true,
      })
    },
  },
}
</script>

