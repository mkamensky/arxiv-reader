<template>
  <div class="q-ma-sm q-gutter-sm wrap">
    <share-network
      v-for="network in $options.networks"
      :key="network.network"
      v-slot="{ share }"
      :network="network.network"
      v-bind="$props"
    >
      <q-btn
        :style="{backgroundColor: network.color}"
        :icon="`$${network.network}`"
        glossy
        :label="network.name"
        @click="share"
      />
    </share-network>
  </div>
</template>

<script>
import { ShareNetwork } from "vue3-social-sharing"

const networks = [
  {
    network: 'email',
    name: 'Email',
    icon: 'far fah fa-lg fa-envelope',
    color: '#333333',
  },
  {
    network: 'evernote',
    name: 'Evernote',
    icon: 'fab fah fa-lg fa-evernote',
    color: '#2dbe60',
  },
  {
    network: 'facebook',
    name: 'Facebook',
    icon: 'fab fah fa-lg fa-facebook-f',
    color: '#1877f2',
  },
  {
    network: 'linkedin',
    name: 'LinkedIn',
    icon: 'fab fah fa-lg fa-linkedin',
    color: '#007bb5',
  },
  {
    network: 'pocket',
    name: 'Pocket',
    icon: 'fab fah fa-lg fa-get-pocket',
    color: '#ef4056',
  },
  {
    network: 'quora',
    name: 'Quora',
    icon: 'fab fah fa-lg fa-quora',
    color: '#a82400',
  },
  {
    network: 'reddit',
    name: 'Reddit',
    icon: 'fab fah fa-lg fa-reddit-alien',
    color: '#ff4500',
  },
  {
    network: 'threads',
    name: 'Threads',
    icon: 'fab fah fa-lg fa-threads',
    color: '#000000',
  },
  {
    network: 'telegram',
    name: 'Telegram',
    icon: 'fab fah fa-lg fa-telegram-plane',
    color: '#0088cc',
  },
  {
    network: 'x',
    name: 'X',
    icon: 'fab fah fa-lg fa-x-twitter',
    color: '#1da1f2',
  },
  {
    network: 'whatsapp',
    name: 'Whatsapp',
    icon: 'fab fah fa-lg fa-whatsapp',
    color: '#25d366',
  },
  {
    network: 'wordpress',
    name: 'Wordpress',
    icon: 'fab fah fa-lg fa-wordpress',
    color: '#21759b',
  },
];

export default {
  components: {
    ShareNetwork,
  },
  networks: networks,
  props: {
    url: {
      type: String,
      required: true,
    },
    title: String,
    description: String,
    quote: String,
    hashtags: String,
    twitterUser: String,
    media: String,
  },
  data() {
    return {
    }
  },
}
</script>

