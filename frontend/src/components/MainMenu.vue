<template>
  <div class="container component-mainmenu d-flex align-items-center">
    <div class="container menu row">
      <b-card title="アンケート登録" class="text-center col">
        <b-card-text>健康調査の記入はこちら</b-card-text>
        <router-link tag="a" class="btn btn-primary" to="/survey"
          >記入する</router-link
        >
      </b-card>
      <b-card title="調査結果閲覧" class="text-center col">
        <b-card-text>健康調査の結果を閲覧するにはこちら</b-card-text>
        <router-link tag="a" class="btn btn-primary" to="/result"
          >調査結果</router-link
        >
      </b-card>
    </div>
  </div>
</template>

<script>
export default {
  name: "MainMenu"
}
</script>

<style scoped>
.container {
  margin-top: 20px;
}
.component-mainmenu {
  height: 100%;
}
</style>