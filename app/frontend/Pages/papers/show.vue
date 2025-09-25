<template>
  <q-page-container>
    <q-page
      padding
      class="q-pt-xl"
    >
      <article>
        <q-responsive ratio="1.6">
          <object
            :data="paper.pdf"
            type="application/pdf"
            width="99%"
            height="99%"
          />
        </q-responsive>
      </article>
    </q-page>
      <q-page-sticky position="top-right" :offset="[18, 10]">

  <q-btn icon="$plus" fab-mini color="accent">
   <q-popup-proxy fit transition-show="scale" transition-hide="scale">
        <div class="q-ma-md">
          <h5>More Info</h5>
          <q-list separator>
            <q-item-label header>
              Authors
            </q-item-label>

            <q-item
              v-for="author in paper.authors"
              :key="author.value"
              v-ripple
              :href="$show_path('authors', author.value)"
              clickable
            >
              <q-item-section avatar>
                <q-icon name="$bulletRight" />
              </q-item-section>
              <q-item-section v-html="$mdi(author.label)" />
            </q-item>
          </q-list>

          <q-list separator>
            <q-item-label header>
              Details
            </q-item-label>
            <q-item>
              <q-item-section>
                <q-item-label overline>
                  Version
                </q-item-label>
                <q-item-label>{{ paper.version }}</q-item-label>
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
            <q-item v-if="revised">
              <q-item-section>
                <q-item-label overline>
                  Revised
                </q-item-label>
                <q-item-label>{{ revised }}</q-item-label>
              </q-item-section>
            </q-item>
            <q-item v-if="paper.journal_ref">
              <q-item-section>
                <q-item-label overline>
                  Journal Ref
                </q-item-label>
                <q-item-label>{{ paper.journal_ref }}</q-item-label>
              </q-item-section>
            </q-item>
            <q-item
              v-for="tag in paper.tags"
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

          <div v-if="paper.comment">
            <h6>Comments</h6>
            <div v-html="$md(paper.comment)" />
          </div>

          <q-btn
            icon="svguse:/icons.svg#arxiv"
            :href="paper.abs"
            color="orange-8"
            text-color="black"
          >
            View on the ArXiv
          </q-btn>
        </div>
    </q-popup-proxy>
  </q-btn>
    </q-page-sticky>

  </q-page-container>

</template>

<script>
export default {
  components: {
  },
  props: {
    paper: Object,
  },
  data() {
    return {
    }
  },
  computed: {
    submitted() {
      return this.dateStr(this.paper.submitted)
    },
    revised() {
      return (
        this.paper.revised != this.paper.submitted &&
        this.dateStr(this.paper.revised)
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
