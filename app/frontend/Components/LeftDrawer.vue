<template>
        <q-btn
        dense
        flat
        rounded
        icon="$menu"
        @click="leftDrawerOpen = !leftDrawerOpen"
        />
  <q-drawer
    v-model="leftDrawerOpen"
    show-if-above
    side="left"
    bordered
    column
    class="text-black"
    >
    <slot />
  </q-drawer>
</template>

<script>
export default {
  components: {
  },
  props: {
  },
  data() {
    return {
      leftDrawerOpen: false,
    }
  },
  computed: {
  },
}
</script>
