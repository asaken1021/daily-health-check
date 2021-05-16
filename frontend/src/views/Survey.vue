<template>
  <div class="container view-survey">
    <SurveyItems />
  </div>
</template>

<script>
import SurveyItems from '@/components/SurveyItems.vue'

export default {
  name: "SurveyPage",
  components: {
    SurveyItems
  }
}
</script>

<style scoped>
.view-survey {
  margin-top: 20px;
}
</style>