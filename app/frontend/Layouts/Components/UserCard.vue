<template>
  <div class="row no-wrap q-pa-md">
    <div class="column">
      <div class="text-h6 q-mb-md">
        Settings
      </div>
    </div>
    <q-separator vertical inset class="q-mx-lg" />
    <div class="column items-center">
      <q-avatar v-if="current_user?.avatar" size="72px">
        <img :src="current_user.avatar">
      </q-avatar>
      <div class="text-subtitle1 q-mb-xs">
        {{ current_user.label }}
      </div>
      <q-btn
        v-close-popup
        color="primary"
        label="Logout"
        push
        size="sm"
        @click="logout"
      />
    </div>
  </div>

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
      <q-list style="max-height: 40%" class="scroll overflow-auto">
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

