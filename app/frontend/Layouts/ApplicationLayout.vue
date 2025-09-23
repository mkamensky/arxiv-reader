<template>
  <Head :title="$page.props.head.title">
    <meta name="description" />
    <meta name="keywords" />
    <link
      rel="stylesheet"
      media="screen"
      href="https://cdn.jsdelivr.net/gh/jpswalsh/academicons/css/academicons.min.css"
    />
  </Head>

  <q-layout view="hHh LpR lFr">

  <slot />

  <q-page-sticky position="bottom-right" :offset="[18, 18]">
    <q-btn :icon="user ? '$loggedin' : '$login'" fab-mini color="accent">
      <q-popup-proxy cover transition-show="scale" transition-hide="scale">
        <q-card>
          <q-form @submit.prevent="submit">
            <q-toolbar glossy>
              <q-toolbar-title>Login</q-toolbar-title>
              <q-btn v-close-popup flat icon="$close" />
            </q-toolbar>
            <q-card-section>
              <q-input
                v-model="form.session.email"
                class="q-mb-md"
                autocomplete="username"
                autofocus
                clearable
                label="Email"
                type="email"
                required
              />
              <q-input
                type="password"
                v-model="form.session.password"
                class="q-mb-md"
                autocomplete="password"
                label="Password"
                clearable
                required
                />


            </q-card-section>
            <q-separator />
            <q-card-actions class="row justify-evenly q-my-md">
              <q-btn color="primary" type="submit" :disabled="form.processing" v-close-popup>
                Submit
              </q-btn>
              <q-space />
                <q-btn color="secondary" type="reset" @click="reset">
                  Reset
                </q-btn>
            </q-card-actions>

          </q-form>
        </q-card>

      </q-popup-proxy>
              </q-btn>
  </q-page-sticky>

  </q-layout>
</template>

<script>
import { Head } from '@inertiajs/vue3'

export default {
  components: {
    Head,
  },
  data() {
    return {
      form: this.$inertia.form('login', {session: { email: '', password: '' }}),
    }
  },
  computed: {
    user() {
      return this.$page.props.auth.user
    },
  },
  methods: {
    reset(evt) {
      evt.preventDefault()
      this.form.reset()
    },
    _success(page) {
      console.log('Success')
      console.log(page)
    },
    _fail(errors) {
      this.$q.notify({type: 'negative', message: errors.base})
    },
    submit(evt) {
      if (evt) evt.preventDefault()
      this.form.submit('post', this.$create_path('sessions'), {
        preserveScroll: true,
        preserveState: true,
        onSuccess: this._success,
        onError: this._fail,
      })
    },
  },
}
</script>
