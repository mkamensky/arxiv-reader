<template>
        <q-btn
        dense
        flat
        rounded
        icon="$menu"
        @click="drawerOpen = !drawerOpen"
        />
  <q-drawer
    v-model="drawerOpen"
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
      drawerOpen: false,
    }
  },
  computed: {
  },
}
</script>
