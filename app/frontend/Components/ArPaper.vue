<template>
  <article>
    <q-card>
      <q-card-actions :class="`${bookmarked(object) ? 'bg-teal-2' : 'bg-secondary'} text-white`">
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
            <!--
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
            -->
            <q-btn
              v-if="current_user"
              :icon="bookmarked(object) ? '$bookmarkOn' : '$bookmark'"
              color="orange-5"
              text-color="black"
              @click="toggleBookmark(object)"
            />
          </q-btn-group>
          <div class="text-subtitle2 q-gutter-md">
            <q-btn-group
              v-for="author in object.authors"
              :key="author.id"
              size="md"
              glossy
              padding="xs"
            >
              <q-btn
                :href="$show_path('authors', author.value)"
                :label="$mdi(author.label)"
                text-color="primary"
                :color="followed(author) ? 'yellow-3' : 'white'"
                glossy
                no-caps
              />
              <q-btn
                v-if="current_user"
                :icon="followed(author) ? '$starRemove' : '$starAdd'"
                text-color="white"
                outline
                @click="toggleFollow(author)"
              />
            </q-btn-group>
          </div>
        </div>
        <q-space />
      </q-card-actions>
      <q-slide-transition>
        <q-card-section
          v-show="show"
          class="text-yellow bg-black"
        >
          <div v-html="$md(object.abstract)" />
        </q-card-section>
      </q-slide-transition>
      <q-card-section class="text-white bg-grey-9 q-pa-sm">
        <q-list dense dark class="row justify-between items-center no-wrap">
          <q-item :href="object.abs" class="bg-teal-9">
            <q-item-section avatar style="min-width: 0px">
              <q-icon name="svguse:/icons.svg#arxiv" />
            </q-item-section>
            <q-item-section>
              <q-item-label overline>
                ArXiv
              </q-item-label>
              <q-item-label>{{ object.value }}</q-item-label>
            </q-item-section>
          </q-item>
          <template v-if="$q.screen.gt.xs">
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
            <q-item v-if="revised">
              <q-item-section>
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
            <q-item v-if="object.primary.length" style="max-width: 30%">
              <q-item-section>
                <q-item-label overline>
                  MSC classes
                </q-item-label>
                <q-item-label>
                  <q-chip
                    v-for="tag in object.primary"
                    :key="tag"
                    dense
                    size="sm"
                  >
                    {{ tag }}<q-tooltip>{{ $options.msc[tag] }}</q-tooltip>
                  </q-chip>
                </q-item-label>
              </q-item-section>
            </q-item>
            <q-item v-if="object.secondary.length" style="max-width: 30%">
              <q-item-section>
                <q-item-label overline>
                  Secondary MSC classes
                </q-item-label>
                <q-item-label>
                  <q-chip
                    v-for="tag in object.primary"
                    :key="tag"
                    dense
                    size="sm"
                  >
                    {{ tag }}<q-tooltip>{{ $options.msc[tag] }}</q-tooltip>
                  </q-chip>
                  v-for="tag in object.secondary"
                  :key="tag"
                </q-item-label>
              </q-item-section>
            </q-item>
          </template>
          <q-item v-if="object.comment || $q.screen.lt.sm">
            <q-item-section avatar class="content-center">
              <q-icon name="$comment">
                <q-tooltip max-width="30rem">
                  <q-list>
                    <template v-if="$q.screen.lt.sm">
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
                      <q-item v-if="revised">
                        <q-item-section>
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
                      <q-item v-if="object.primary.length" style="max-width: 30%">
                        <q-item-section>
                          <q-item-label overline>
                            MSC classes
                          </q-item-label>
                          <q-item-label>
                            <q-chip
                              v-for="tag in object.primary"
                              :key="tag"
                              dense
                              size="sm"
                            >
                              {{ tag }}<q-tooltip>{{ $options.msc[tag] }}</q-tooltip>
                            </q-chip>
                          </q-item-label>
                        </q-item-section>
                      </q-item>
                      <q-item v-if="object.secondary.length" style="max-width: 30%">
                        <q-item-section>
                          <q-item-label overline>
                            Secondary MSC classes
                          </q-item-label>
                          <q-item-label>
                            <q-chip
                              v-for="tag in object.primary"
                              :key="tag"
                              dense
                              size="sm"
                            >
                              {{ tag }}<q-tooltip>{{ $options.msc[tag] }}</q-tooltip>
                            </q-chip>
                            v-for="tag in object.secondary"
                            :key="tag"
                          </q-item-label>
                        </q-item-section>
                      </q-item>
                    </template>
                    <q-item>
                      <q-item-section>
                        <q-item-label v-html="$md(object.comment)" />
                      </q-item-section>
                    </q-item>
                  </q-list>
                </q-tooltip>
              </q-icon>
            </q-item-section>
          </q-item>
          <q-item>
            <q-btn
              :icon="show ? '$hide' : '$show'"
              flat
              dense
              round
              class="bg-red-2 text-black"
              title="Toggle abstract"
              @click="show = !show"
            />
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>
  </article>
</template>

<script>
import userMixin from '@/mixins/userMixin'
import { mscDesc } from './mscDesc.js'

export default {
  mixins: [userMixin],
  props: {
    object: {
      type: Object,
    },
  },
  msc: mscDesc,
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
      return new Date(date)?.toLocaleDateString(undefined, {
        day: 'numeric', month: 'short', year: 'numeric'
      }) || date
    },
  },
}
</script>
