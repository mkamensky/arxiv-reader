<template>
  <q-tabs no-caps>
    <q-route-tab
      v-for="item in items"
      :key="item.arxiv"
      :name="item.arxiv"
      :href="$show_path(type, item.arxiv)"
      :label="item.arxiv"
    />
  </q-tabs>
</template>

<script>
export default {
  props: {
    items: {
      type: Array,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
  },
}
</script>
