<template>
  <article>
    <q-card>
      <q-card-actions class="bg-teal text-white">
        <div>
          <q-btn-group
            push
            class="q-mb-sm"
          >
            <q-btn
              :href="$show_path('papers', object.value)"
              color="amber"
              text-color="black"
              no-caps
            >
              <span v-html="$mdi(object.label)" />
            </q-btn>
            <q-btn
              icon="$pdf"
              :href="object.pdf"
              color="orange"
              text-color="black"
              dense
            />
            <q-btn
              icon="$download"
              :href="object.pdf"
              color="orange-7"
              text-color="black"
              dense
              :download="`${object.value}.pdf`"
            />
            <q-btn
              icon="svguse:/icons.svg#arxiv"
              :href="object.abs"
              color="orange-8"
              text-color="black"
              dense
            />
          </q-btn-group>
          <div class="text-subtitle2 q-gutter-md">
            <q-btn
              v-for="author in object.authors"
              :key="author.id"
              :href="$show_path('authors', author.value)"
              :label="$mdi(author.label)"
              text-color="primary"
              color="white"
              no-caps
              size="md"
              glossy
              padding="xs"
            />
          </div>
        </div>
        <q-space />
        <q-btn
          :icon="show ? '$hide' : '$show'"
          flat
          dense
          round
          class="bg-red-2 text-black"
          @click="show = !show"
        />
      </q-card-actions>
      <q-slide-transition>
        <q-card-section
          v-show="show"
          class="text-yellow bg-black"
        >
          <div v-html="$md(object.abstract)" />
        </q-card-section>
      </q-slide-transition>
      <q-slide-transition>
        <q-card-section
          v-show="show"
          class="text-white bg-grey-9"
        >
          <div class="row">
            <q-list
              dense
              dark
              class="row col"
            >
              <q-item>
                <q-item-section>
                  <q-item-label overline>
                    Version
                  </q-item-label>
                  <q-item-label>{{ object.version }}</q-item-label>
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section>
                  <q-item-label overline>
                    Submitted
                  </q-item-label>
                  <q-item-label>{{ submitted }}</q-item-label>
                </q-item-section>
              </q-item>
              <q-item>
                <q-item-section v-if="revised">
                  <q-item-label overline>
                    Revised
                  </q-item-label>
                  <q-item-label>{{ revised }}</q-item-label>
                </q-item-section>
              </q-item>
              <q-item v-if="object.journal_ref">
                <q-item-section>
                  <q-item-label overline>
                    Journal Ref
                  </q-item-label>
                  <q-item-label>{{ object.journal_ref }}</q-item-label>
                </q-item-section>
              </q-item>
              <q-item
                v-for="tag in object.tags"
                :key="tag"
              >
                <q-item-section>
                  <q-item-label overline>
                    MSC classes
                  </q-item-label>
                  <q-item-label>{{ tag }}</q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
            <div
              v-if="object.comment"
              class="col"
              v-html="$md(object.comment)"
            />
          </div>
        </q-card-section>
      </q-slide-transition>
    </q-card>
  </article>
</template>

<script>
export default {
  props: {
    object: {
      type: Object,
    },
  },
  data() {
    return {
      show: true,
    }
  },
  computed: {
    submitted() {
      return this.dateStr(this.object.submitted)
    },
    revised() {
      return (
        this.object.revised != this.object.submitted &&
        this.dateStr(this.object.revised)
      )
    },
  },
  methods: {
    dateStr(date) {
      return new Date(date)?.toDateString() || date
    },
  },
}
</script>
