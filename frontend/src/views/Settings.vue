<template>
  <div class="container view-settings">
    <SettingItems />
  </div>
</template>

<script>
import SettingItems from '@/components/SettingItems.vue'

export default {
  name: "SettingsPage",
  components: {
    SettingItems
  }
}
</script>

<style scoped>
.view-settings {
  margin-top: 20px;
}
</style>
