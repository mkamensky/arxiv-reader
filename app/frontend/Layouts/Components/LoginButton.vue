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
import userMixin from '@/mixins/userMixin'


export default {
  components: {
    LoginForm,
    UserCard,
  },
  mixins: [userMixin],
  props: {
  },
  data() {
    return {
    }
  },
}
</script>

