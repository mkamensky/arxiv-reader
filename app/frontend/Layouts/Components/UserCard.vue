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

  <!-- Paper lists -->
  <sidebar-list
    label="Followed authors"
    type="authors"
    :list="user.fauthors || []"
    :item-papers="author_papers"
    :other-papers="other_papers"
    other-label="Other Bookmarked Papers"
    @remove-item="removeAuthor"
  />

  <q-separator class="q-my-sm" />

  <sidebar-list
    label="User Tags"
    type="tags"
    :list="user.tags || []"
    @remove-item="deleteTag"
  />
</template>

<script>
import userMixin from '@/mixins/userMixin'
import SidebarList from '@/Layouts/Components/SidebarList.vue'

export default {
  components: {
    SidebarList,
  },
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

