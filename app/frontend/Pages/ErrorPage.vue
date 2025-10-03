<template>
  <div>
    <h1>{{ status }}: {{ title }}</h1>
    <div>{{ description }}</div>
    <div>{{ message }}</div>
  </div>
</template>

<script>

export default {
  props: {
    status: Number,
    message: String,
  },
  computed: {
    title() {
      return {
        503: 'Service Unavailable',
        500: 'Server Error',
        404: 'Page Not Found',
        403: 'Forbidden',
      }[this.status] || 'Unexpected error'
    },
    description() {
      return {
        503: 'Sorry, we are doing some maintenance. Please check back soon.',
        500: 'Whoops, something went wrong on our servers.',
        404: 'Sorry, the page you are looking for could not be found.',
        403: 'Sorry, you are forbidden from accessing this page.',
      }[this.status]
    },
  },
}
</script>

