export default {
  computed: {
    current_user() {
      return this.$page?.props?.auth?.user
    },
    user() {
      return this.current_user ||
        this.$q?.localStorage?.getItem('current_user')
    },
    bpapers() {
      return new Set(this.user?.bpapers?.map(it => it.id) || [])
    },
    fauthors() {
      return new Set(this.user?.fauthors?.map(it => it.id) || [])
    },
    tagged() {
      return this.user?.tags.reduce(
        (res, elem) => {
          res[elem.value] = new Set(elem.papers.map(p => p.id))
          return res
        }, {})
    },
    hidden_ids() {
      return new Set(this.user?.hidden_ids || [])
    },
    // bookmarked papers not authored by any followed author
    other_papers() {
      return this.user.bpapers.
        filter(paper =>
          this.fauthors.intersection(
            new Set(paper.authors.map(it => it.id))
          ).size == 0)
    },
  },
  methods: {
    hasItem(list, item) {
      return this[list].has(item.id)
    },
    hasTagged(tag, item) {
      return this.tagged[tag].has(item.id)
    },
    addToList(list, item) {
      if (!this.hasItem(list, item)) {
        if (this.current_user) {
          this.current_user[list].push(item)
          this.updateList(list)
        } else {
          const val = this.$q.localStorage.getItem(list) || []
          val.push(item.id)
          this.$q.localStorage.set(list, val)
        }
      }
    },
    findTag(tag) {
      return this.user?.tags?.find(it => it.value == tag)
    },
    addToTagged(tag, item) {
      if (this.hasTagged(tag, item)) {
        return
      }
      const tt = this.findTag(tag)
      if (tt) {
        tt.papers ??= []
        tt.papers.push(item)
        this.updateTags()
      }
    },
    removeItem(list, item) {
      if (this.hasItem(list, item)) {
        if (this.current_user) {
          this.current_user[list] =
            this.current_user[list]
            .filter(it => it.id != item.id)
          this.updateList(list)
        } else {
          const val = this.$q.localStorage.getItem(list) || []
          this.$q.localStorage.set(list, val.filter(it => it != item.id))
        }
      }
    },
    removeTagged(tag, item) {
      if (!this.hasTag(tag, item)) {
        return
      }

      const tt = this.findTag(tag)
      if (tt) {
        tt.papers ??= []
        tt.papers = tt.papers.filter(it => it.id != item.id)
        this.updateTags()
      }
    },
    updateList(list, ids = null) {
      ids ??= list.replace(/s$/, '_ids')
      this.$inertia.patch(this.$update_path('users', this.current_user.id), {
        user: { [ids]: Array.from(this[list]), },
      }, {
        only: [list],
        preserveScroll: true,
        preserveState: true,
      })
    },
    updateTags() {
      if (this.current_user) {
        this.$inertia.patch(
          this.$update_path('users', this.current_user.id),
          {
            user: {
              tags_attributes: this.user.tags.map(it =>
                ({ id: it.id, paper_ids: Array.from(this.tagged[it.value]) })
              )},
          }, {
          only: ['tags_attributes'],
          preserveScroll: true,
          preserveState: true,
        })
      } else {
        this.$q.localStorage.set('current_user', this.user)
      }
    },
    toggleListItem(list, item) {
      if (this.hasItem(list, item)) {
        this.removeItem(list, item)
      } else {
        this.addToList(list, item)
      }
    },
    toggleTaggedItem(tag, item) {
      if (this.hasTagged(tag, item)) {
        this.removeTagged(tag, item)
      } else {
        this.addToTagged(tag, item)
      }
    },
    toggleBookmark(paper, tag = null) {
      return tag ? this.toggleTaggedItem(tag, paper) : this.toggleListItem('bpapers', paper)
    },
    bookmarked(paper, tag = null) {
      return tag ? this.hasTagged(tag, paper) : this.hasItem('bpapers', paper)
    },
    bookmark(paper) {
      return this.addToList('bpapers', paper)
    },
    removeBookmark(paper) {
      return this.removeItem('bpapers', paper)
    },
    followed(author) {
      return this.hasItem('fauthors', author)
    },
    follow(author) {
      return this.addToList('fauthors', author)
    },
    removeAuthor(author) {
      return this.removeItem('fauthors', author)
    },
    toggleFollow(author) {
      return this.toggleListItem('fauthors', author)
    },
    isHidden(paper) {
      return this.hasItem('hidden_ids', paper)
    },
    hidePaper(paper) {
      if (!this.hasItem('hidden_ids', paper)) {
        if (this.current_user) {
          this.current_user.hidden_ids ??= []
          this.current_user.hidden_ids.push(paper.id)
          return this.updateList('hidden_ids', 'hidden_ids')
        } else {
          this.addToList('hidden_ids', paper)
        }
      }
    },
    author_papers(author) {
      return this.current_user.bpapers.
        filter(paper => paper.authors.findIndex(it => it.id === author.id) >= 0)
    },
  },
}

