import { router } from '@inertiajs/vue3'

export default {
  computed: {
    current_user() {
      return this.$page.props.auth.user
    },
    bpapers() {
      return new Set(this.current_user?.bpapers?.map(it => it.id) || [])
    },
    stars() {
      return new Set(this.current_user?.starred?.map(it => it.id) || [])
    },
    fauthors() {
      return new Set(this.current_user?.fauthors?.map(it => it.id) || [])
    },


  },
  methods: {
    bookmarked(paper) {
      return this.bpapers.has(paper.id)
    },
    starred(paper) {
      return this.stars.has(paper.id)
    },
    followed(author) {
      return this.fauthors.has(author.id)
    },
    bookmark(paper) {
      if (!this.bookmarked(paper)) {
        this.current_user.bpapers.push(paper)
        this.updateBookmarks()
      }
    },
    removeBookmark(paper) {
      if (this.bookmarked(paper)) {
        this.current_user.bpapers =
          this.current_user.bpapers
          .filter(it => it.id != paper.id)
        this.updateBookmarks()
      }
    },
    updateBookmarks() {
        router.patch(this.$update_path('users', this.current_user.id), {
          user: { bpaper_ids: Array.from(this.bpapers), },
        }, {
          only: ['bpapers'],
          preserveScroll: true,
          preserveState: true,
        })
    },
    star(paper) {
      if (!this.starred(paper)) {
        this.current_user.starred.push(paper)
      }
    },
    follow(author) {
      if (!this.followed(author)) {
        this.current_user.followed.push(author)
      }
    },
  },
}

