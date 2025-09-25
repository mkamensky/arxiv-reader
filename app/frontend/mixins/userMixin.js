export default {
  computed: {
    current_user() {
      return this.$page.props.auth.user
    },
  },
}

