<template>
  <q-btn :icon="current_user ? '$loggedin' : '$login'" fab-mini color="accent">
    <q-popup-proxy cover transition-show="scale" transition-hide="scale">
      <q-card>
        <q-toolbar glossy>
          <q-toolbar-title>
            <q-tabs v-model="tab" class="text-teal">
              <q-tab label="Login" name="sessions" />
              <q-tab label="Sign Up" name="users" />
            </q-tabs>
          </q-toolbar-title>
          <q-btn v-close-popup flat icon="$close" />
        </q-toolbar>

        <q-separator />

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="sessions">
            <q-form @submit.prevent="submit">
              <q-card-section>
                <q-input
                  v-model="session.email"
                  class="q-mb-md"
                  autocomplete="email"
                  autofocus
                  clearable
                  label="Email"
                  type="email"
                  required
                  />
                <q-input
                  type="password"
                  v-model="session.password"
                  class="q-mb-md"
                  autocomplete="current-password"
                  label="Password"
                  clearable
                  required
                  />
              </q-card-section>

              <q-separator />

              <q-card-actions class="row justify-evenly q-my-md">
                <q-btn
                  color="primary"
                  type="submit"
                  :disabled="form.processing"
                  v-close-popup
                  >
                  Submit
                </q-btn>
                <q-space />
                <q-btn color="secondary" type="reset" @click="reset">
                  Reset
                </q-btn>
              </q-card-actions>

            </q-form>
          </q-tab-panel>

          <q-tab-panel name="users">
            <q-form @submit.prevent="submit">
              <q-card-section>
                <q-input
                  v-model="user.email"
                  class="q-mb-md"
                  autocomplete="email"
                  autofocus
                  clearable
                  label="Email"
                  type="email"
                  required
                  />
                <q-input
                  type="password"
                  v-model="user.password"
                  class="q-mb-md"
                  autocomplete="new-password"
                  label="Password"
                  clearable
                  required
                  />
                <q-input
                  v-model="user.name"
                  class="q-mb-md"
                  autocomplete="name"
                  autofocus
                  clearable
                  label="Full name"
                  type="text"
                  required
                  />
              </q-card-section>
              <q-separator />
              <q-card-actions class="row justify-evenly q-my-md">
                <q-btn
                  color="primary"
                  type="submit"
                  :disabled="form.processing"
                  v-close-popup
                  >
                  Submit
                </q-btn>
                <q-space />
                <q-btn color="secondary" type="reset" @click="reset">
                  Reset
                </q-btn>
              </q-card-actions>

            </q-form>
          </q-tab-panel>
        </q-tab-panels>
      </q-card>

    </q-popup-proxy>
  </q-btn>
</template>

<script>
export default {
  components: {
  },
  props: {
  },
  data() {
    return {
      tab: 'sessions',
      forms: {
        sessions: this.$inertia.form('sessions', {
          session: { email: '', password: '' }
        }),
        users: this.$inertia.form('users', {
          user: { email: '', password: '', name: '' }
        }),
      },
    }
  },
  computed: {
    current_user() {
      return this.$page.props.auth.user
    },
    form() {
      return this.forms[this.tab]
    },
    path() {
      return this.$create_path(this.tab)
    },
    session() {
      return this.forms.sessions.session
    },
    user() {
      return this.forms.users.user
    },
  },
  methods: {
    reset(evt) {
      evt.preventDefault()
      this.form.reset()
    },
    success(page) {
    },
    fail(errors) {
      this.$q.notify({type: 'negative', message: errors.base})
    },
    submit(evt) {
      if (evt) evt.preventDefault()
      this.form.submit('post', this.path, {
        preserveScroll: true,
        preserveState: true,
        //onSuccess: this.success,
        onError: this.fail,
      })
    },
  },
}
</script>

