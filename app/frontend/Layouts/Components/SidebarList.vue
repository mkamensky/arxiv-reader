<template>
  <q-toolbar class="bg-info text-black">
    <q-toolbar-title v-html="label" />
  </q-toolbar>
  <q-list style="max-height: 80%" dense class="scroll overflow-auto">
    <q-expansion-item
      v-for="item in list || []"
      :key="item.value"
      expand-icon-toggle
      expand-separator
      :hide-expand-icon="itemPapers(item).length == 0"
    >
      <template #header>
        <q-item-section avatar>
          <q-btn
            round
            size="xs"
            icon="$close"
            class="bg-secondary text-white"
            @click="$emit('remove-item', item)"
          />
        </q-item-section>
        <q-item-section>
          <q-btn
            ripple
            flat
            align="left"
            :color="item.color || 'warning'"
            no-caps
            class="q-px-none"
            :href="$show_path(type, item.value)"
          >
            <q-item-label>{{ item.label }}</q-item-label>
          </q-btn>
        </q-item-section>
      </template>
      <paper-list :papers="itemPapers(item)" />
    </q-expansion-item>
    <q-expansion-item
      v-if="otherPapers.length > 0"
      expand-separator
      :label="otherLabel"
      icon="$menu"
      header-class="text-warning"
    >
      <paper-list :papers="otherPapers" />
    </q-expansion-item>
  </q-list>
</template>

<script>

import PaperList from '@/Layouts/Components/PaperList.vue'

export default {
  components: {
    PaperList,
  },
  props: {
    label: String,
    type: String,
    list: Array,
    itemPapers: {
      type: Function,
      default: item => item.papers,
    },
    otherPapers: {
      type: Array,
      default: () => [],
    },
    otherLabel: String,
  },
  emits: ['remove-item'],
  data() {
    return {
    }
  },
  computed: {
  },
}
</script>

<style lang="scss" scoped>
</style>

