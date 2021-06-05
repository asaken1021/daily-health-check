<template>
  <div class="container view-main">
    <MainMenu />
  </div>
</template>

<script>
import MainMenu from '@/components/MainMenu.vue'

export default {
  name: "MainPage",
  components: {
    MainMenu
  }
}
</script>

<style scoped>
.view-main {
  height: calc(100vh - 112px - 1rem);
}
</style>