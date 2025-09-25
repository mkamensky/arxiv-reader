<template>
  <q-btn
    :icon="current_user ? '$loggedin' : '$login'"
    fab-mini
    color="accent"
  >
    <q-popup-proxy
      fit
      transition-show="scale"
      transition-hide="scale"
    >
      <user-card v-if="current_user" />
      <login-form v-else />
    </q-popup-proxy>
  </q-btn>
</template>

<script>
import LoginForm from '@/Layouts/Components/LoginForm.vue'
import UserCard from '@/Layouts/Components/UserCard.vue'

export default {
  components: {
    LoginForm,
    UserCard,
  },
  props: {
  },
  data() {
    return {
    }
  },
  computed: {
    current_user() {
      return this.$page.props.auth.user
    },
  },
}
</script>

