<template>
  <div class="column fit">
    <q-card class="q-mb-lg">
      <q-toolbar glossy>
        <q-toolbar-title>
          <q-tabs
            v-model="tab"
            class="text-teal"
          >
            <q-tab label="Login" name="sessions" />
            <q-tab label="Sign Up" name="users" />
          </q-tabs>
        </q-toolbar-title>
      </q-toolbar>

      <q-separator />

      <q-tab-panels
        v-model="tab"
        animated
      >
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
                error-message="Please enter a valid email"
              />
              <q-input
                v-model="session.password"
                :type="showPwd ? 'text' : 'password'"
                class="q-mb-md"
                autocomplete="current-password"
                label="Password"
                clearable
                required
              >
                <template #append>
                  <q-icon
                    :name="showPwd ? '$visible' : '$invisible'"
                    class="cursor-pointer"
                    @click="showPwd = !showPwd"
                  />
                </template>
              </q-input>
            </q-card-section>

            <q-separator />

            <q-card-actions class="row justify-evenly q-my-md">
              <q-btn
                color="primary"
                type="submit"
                :disabled="form.processing"
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
                v-model="user.password"
                :type="showPwd ? 'text' : 'password'"
                class="q-mb-md"
                autocomplete="new-password"
                label="Password"
                clearable
                required
              >
                <template #append>
                  <q-icon
                    :name="showPwd ? '$visible' : '$invisible'"
                    class="cursor-pointer"
                    @click="showPwd = !showPwd"
                  />
                </template>
              </q-input>

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

    <q-card class="q-my-lg">
      <q-toolbar class="bg-secondary" glossy>
        <q-toolbar-title>Or, login/sign-up via:</q-toolbar-title>
      </q-toolbar>

      <q-separator dark inset />

      <q-card-section class="row wrap justify-evenly q-my-md">
        <q-form
          v-for="service in $options.services"
          :key="service"
          :action="`/auth/${service}`"
          method="post"
          class="col q-mx-sm"
        >
          <input type="hidden" name="authenticity_token" :value="xsrf">
          <q-btn
            color="primary"
            type="submit"
            :label="service"
            :icon="`$${service}`"
            class="absolute-center full-width"
          >
            <q-tooltip>Login with {{ service }}</q-tooltip>
          </q-btn>
          <q-separator vertical inset dark />
        </q-form>
      </q-card-section>
    </q-card>
  </div>
</template>

<script>

export default {
  components: {
  },
  services: ['github', 'google', 'orcid'],
  data() {
    return {
      tab: 'sessions',
      showPwd: false,
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
    xsrf() {
      const splitCookies = document.cookie.split('; ');
      return splitCookies
        .find(cookie => cookie.startsWith("XSRF-TOKEN="))
        .split('=')[1]
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
    fail(errors) {
      this.$q.notify({type: 'negative', message: errors.base})
    },
    submit(evt) {
      if (evt) evt.preventDefault()
      this.form.post(this.path, {
        preserveScroll: true,
        preserveState: true,
        //onSuccess: this.success,
        onError: this.fail,
      })
    },
  },
}
</script>

