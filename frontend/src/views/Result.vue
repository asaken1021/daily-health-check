<template>
  <div class="container view-result">
    <ResultList />
  </div>
</template>

<script>
import ResultList from '@/components/ResultList.vue'

export default {
  name: "ResultPage",
  components: {
    ResultList
  }
}
</script>

<style scoped>
.view-result {
  margin-top: 20px;
}
</style>
