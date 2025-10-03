import { router } from '@inertiajs/vue3'

export default {
  computed: {
    current_user() {
      return this.$page.props.auth.user
    },
    bpapers() {
      return new Set(this.current_user?.bpapers?.map(it => it.id) || [])
    },
    fauthors() {
      return new Set(this.current_user?.fauthors?.map(it => it.id) || [])
    },
  },
  methods: {
    hasItem(list, item) {
      return this[list].has(item.id)
    },
    addToList(list, item) {
      if (!this.hasItem(list, item)) {
        this.current_user[list].push(item)
        this.updateList(list)
      }
    },
    removeItem(list, item) {
      if (this.hasItem(list, item)) {
        this.current_user[list] =
          this.current_user[list]
          .filter(it => it.id != item.id)
        this.updateList(list)
      }
    },
    updateList(list, ids = null) {
      ids ??= list.replace(/s$/, '_ids')
      router.patch(this.$update_path('users', this.current_user.id), {
        user: { [ids]: Array.from(this[list]), },
      }, {
        only: [list],
        preserveScroll: false,
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
  },
}

