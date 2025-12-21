<template>
  <q-btn icon="$share" title="Share">
    <q-popup-proxy
      transition-show="scale"
      transition-hide="scale"
      style="max-width: 600px"
    >
      <q-toolbar glossy class="bg-primary">
        <q-toolbar-title>Share paper to...</q-toolbar-title>
      </q-toolbar>
      <social-share
        v-close-popup
        :url="fullUrl"
        :title="`**${paper.label}**`"
        :description="paper.abstract"
      />
    </q-popup-proxy>
  </q-btn>
</template>

<script>
import SocialShare from '@/Components/SocialShare.vue'

export default {
  components: {
    SocialShare,
  },
  props: {
    paper: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
    }
  },
  computed: {
    fullUrl() {
      return window.location.origin + this.$show_path('papers', this.paper.value)
    },
  },
}
</script>

