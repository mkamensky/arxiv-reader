<template>
  <q-card class="q-mb-sm">
    <q-card-section horizontal>
      <q-card-section class="q-pt-xs">
        <div class="text-overline">
          {{ current_user.value }}
        </div>
        <div class="text-h5 q-mt-sm q-mb-xs">
          {{ current_user.label }}
        </div>
      </q-card-section>
      <q-card-section v-if="current_user?.avatar" class="col-5 flex flex-center">
        <q-avatar size="72px">
          <img :src="current_user.avatar">
        </q-avatar>
      </q-card-section>
    </q-card-section>
    <q-card-actions>
      <q-btn
        color="primary"
        label="Logout"
        push
        size="sm"
        @click="logout"
      />
    </q-card-actions>
  </q-card>

  <q-splitter
    v-model="splitterModel"
    style="height: 92%"
    horizontal
  >
    <template #before>
      <q-toolbar class="bg-info text-black">
        <q-toolbar-title>Bookmarked papers</q-toolbar-title>
      </q-toolbar>
      <q-list class="scroll overflow-auto">
        <q-item
          v-for="item in current_user.bpapers || []"
          :key="item.value"
        >
          <q-item-section>
            <q-btn no-caps flat :href="$show_path('papers', item.value)">
              <q-item-label>{{ item.label }}</q-item-label>
              <q-item-label caption>
                {{ item.authors.map(it => it.label).join(', ') }}
              </q-item-label>
            </q-btn>
          </q-item-section>
          <q-item-section side>
            <q-btn
              round
              size="sm"
              icon="$close"
              class="bg-secondary text-white"
              @click="removeBookmark(item)"
            />
          </q-item-section>
        </q-item>
      </q-list>
    </template>
    <template #after>
      <q-toolbar class="bg-info text-black">
        <q-toolbar-title>
          Followed authors
        </q-toolbar-title>
      </q-toolbar>
      <q-list style="max-height: 80%" dense class="scroll overflow-auto">
        <q-item
          v-for="item in current_user.fauthors || []"
          :key="item.value"
        >
          <q-item-section>
            <q-btn no-caps flat :href="$show_path('authors', item.value)">
              <q-item-label>{{ item.label }}</q-item-label>
            </q-btn>
          </q-item-section>
          <q-item-section side>
            <q-btn
              round
              size="xs"
              icon="$close"
              class="bg-secondary text-white"
              @click="removeAuthor(item)"
            />
          </q-item-section>
        </q-item>
      </q-list>
    </template>
  </q-splitter>
</template>

<script>
import userMixin from '@/mixins/userMixin'

export default {
  mixins: [userMixin],
  data() {
    return {
      splitterModel: 50,
    }
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

