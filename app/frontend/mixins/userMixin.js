export default {
  computed: {
    current_user() {
      return this.$page?.props?.auth?.user
    },
    bpapers() {
      return new Set(
        this.current_user?.bpapers?.map(it => it.id) ||
        this.$q?.localStorage?.getItem('bpapers') ||
        []
      )
    },
    fauthors() {
      return new Set(this.current_user?.fauthors?.map(it => it.id) ||
        this.$q?.localStorage?.getItem('fauthors') ||
        []
      )
    },
    hidden_ids() {
      return new Set(this.current_user?.hidden_ids ||
        this.$q?.localStorage?.getItem('hidden_ids') ||
        []
      )
    },
    // bookmarked papers not authored by any followed author
    other_papers() {
      return this.current_user.bpapers.
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
    toggleListItem(list, item) {
      if (this.hasItem(list, item)) {
        this.removeItem(list, item)
      } else {
        this.addToList(list, item)
      }
    },
    toggleBookmark(paper) {
      return this.toggleListItem('bpapers', paper)
    },
    bookmarked(paper) {
      return this.hasItem('bpapers', paper)
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

