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
  <q-splitter v-model="splitter" horizontal :style="{height: '80%'}">
    <template #before>
      <sidebar-list
        label="Followed authors"
        type="authors"
        :list="user.fauthors || []"
        :item-papers="author_papers"
        :other-papers="other_papers"
        other-label="Other Bookmarked Papers"
        @modify-item="removeAuthor"
      />
    </template>

    <template #after>
      <sidebar-list
        label="User Tags"
        type="tags"
        :list="user.tags || []"
        icon="$edit"
        @modify-item="editTag"
      >
        <q-btn
          icon="$plus"
          color="accent"
          fab-mini
          @click="tagDialog = true"
        />
      </sidebar-list>
    </template>
  </q-splitter>
  <q-dialog v-model="tagDialog">
    <q-card>
      <q-form @submit.prevent="addTag" @reset="resetForm">
        <q-toolbar class="bg-secondary glossy">
          <q-toolbar-title>New Tag</q-toolbar-title>
          <q-btn v-close-popup flat icon="$close" />
        </q-toolbar>
        <q-card-section class="q-gutter-md">
          <q-banner
            v-if="showErrors && formErrors"
            dense
            rounded
            inline-actions
            class="text-negative"
          >
            {{ formErrors }}
            <template #action>
              <q-btn
                round
                flat
                fab-mini
                size="xs"
                class="bg-info"
                icon="$close"
                @click="showErrors = false"
              />
            </template>
          </q-banner>
          <q-input
            v-model="newTag.val"
            filled
            label="Tag value"
            hint="Short tag id without whitespace"
            :error="!!errors.val"
            :error-message="errors.val"
            lazy-rules
            :rules="[ val => val && val.length > 0 && !val.includes(' ') || 'invalid tag']"
          />
          <q-input
            v-model="newTag.title"
            filled
            label="Tag title"
            :error="!!errors.title"
            :error-message="errors.title"
          />
          <q-input
            v-model="newTag.color"
            filled
            label="Color"
            :error="!!errors.color"
            :error-message="errors.color"
            :rules="['anyColor']"
          >
            <template #append>
              <q-icon name="$colorize" class="cursor-pointer">
                <q-popup-proxy cover>
                  <q-color v-model="newTag.color" format-model="hex" />
                </q-popup-proxy>
              </q-icon>
            </template>
          </q-input>
        </q-card-section>
        <q-card-actions class="row justify-evenly q-my-md" dense>
          <q-btn color="primary" type="submit" :disabled="form.processing">
            Submit
          </q-btn>
          <q-space />
          <q-btn
            v-if="newTag.id"
            v-close-popup
            color="warning"
            @click="deleteTag"
          >
            Delete
          </q-btn>
          <q-space />
          <q-btn color="secondary" type="reset">
            Reset
          </q-btn>
        </q-card-actions>
      </q-form>
    </q-card>
  </q-dialog>
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
    const uu = this.$page.props.auth.user
    const ff= uu.fauthors.length + 1
    return {
      tagDialog: false,
      showErrors: true,
      splitter: Math.min(70, Math.floor(ff * 100 / (ff + uu.tags.length))),
      form: this.$inertia.form('tags', {
        tag: {
          color: '',
          title: '',
          val: '',
        },
      }),
    }
  },
  computed: {
    newTag() {
      return this.form.tag
    },
    errors() {
      return this.form.errors
    },
    formErrors() {
      return this.errors && Object.keys(this.errors).length > 0
        ? this.errors['base'] || 'Please correct form errors'
        : null
    },
    submitPath() {
      return this.newTag.id ? this.$update_path('tags', this.newTag.id) : this.$create_path('tags')
    },
  },
  methods: {
    addTag(evt) {
      if (evt) evt.preventDefault()
      this.form.submit(this.newTag.id ? 'patch': 'post', this.submitPath, {
        preserveScroll: true,
        preserveState: true,
        onSuccess() { this.form.reset(); this.tagDialog = false },
      })
    },
    editTag(item) {
      this.newTag.color = item.color
      this.newTag.title = item.label
      this.newTag.val = item.value
      this.newTag.id = item.id
      this.tagDialog = true
    },
    deleteTag() {
      this.$inertia.delete(this.$destroy_path('tags', this.newTag.id), {
        preserveScroll: true,
        preserveState: true,
        onSuccess() { this.form.reset(); this.tagDialog = false },
      })
    },
    resetForm() {
      this.form.reset()
    },
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

