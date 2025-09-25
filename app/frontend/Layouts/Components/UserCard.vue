<template>
  <div class="row no-wrap q-pa-md">
    <div class="column">
      <div class="text-h6 q-mb-md">Settings</div>
    </div>

    <q-separator vertical inset class="q-mx-lg" />

    <div class="column items-center">
      <q-avatar v-if="current_user?.avatar" size="72px">
        <img :src="current_user.avatar">
      </q-avatar>

      <div class="text-subtitle1 q-mb-xs">{{ current_user.label }}</div>

      <q-btn
        color="primary"
        label="Logout"
        push
        size="sm"
        v-close-popup
        @click="logout"
      />
    </div>
  </div>
</template>

<script>
import { router } from '@inertiajs/vue3'
export default {
  data() {
    return {
    }
  },
  computed: {
    current_user() {
      return this.$page.props.auth.user
    },
  },
  methods: {
    logout(evt) {
      if (evt) evt.preventDefault()
      router.delete(this.$create_path('sessions'), {
        preserveScroll: true,
        preserveState: true,
      })
    },
  },
}
</script>

