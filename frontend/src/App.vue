<template>
  <div id="app">
    <b-navbar togglable="lg" class="nav-custom">
      <div class="container">
        <b-navbar-brand class="nav-text-color" href="/"
          >健康調査アンケート</b-navbar-brand
        >
      </div>
    </b-navbar>
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
  components: {
  }
}
</script>

<style scoped>
/* #app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #cfcfcf;
  margin-top: 60px;
} */
.nav-custom {
  background-color: #1e2088;
}
.nav-text-color {
  color: #cfcfcf !important;
}
</style>
