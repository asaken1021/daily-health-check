<template>
  <div class="component-authmodal">
    <b-modal id="modal-registration" title="ユーザー登録" size="lg" centered>
      <b-form-input
        v-model="user.name"
        type="text"
        name="name"
        placeholder="名前"
      ></b-form-input>
      <b-form-input
        v-model="user.email"
        type="email"
        name="email"
        placeholder="メールアドレス"
      ></b-form-input>
      <b-form-input
        v-model="user.password"
        type="password"
        name="password"
        placeholder="パスワード(6文字以上24文字以内)"
      ></b-form-input>
      <b-form-input
        v-model="user.password_confirmation"
        type="password"
        name="password_confirmation"
        placeholder="パスワード(確認)"
      ></b-form-input>
      <b-form-input
        v-model="user.shared_key"
        type="text"
        name="shared_key"
        placeholder="事前共有キー"
      ></b-form-input>
      <template v-slot:modal-footer>
        <b-button
          variant="secondary"
          @click="$bvModal.hide('modal-registration')"
          >キャンセル</b-button
        >
        <b-button variant="primary" @click="registration">登録</b-button>
      </template>
    </b-modal>

    <b-modal id="modal-auth" title="ユーザー認証" size="lg" centered>
      <b-form-input
        v-model="user.email"
        type="email"
        name="email"
        placeholder="メールアドレス"
      ></b-form-input>
      <b-form-input
        v-model="user.password"
        type="password"
        name="password"
        placeholder="パスワード"
      ></b-form-input>
      <template v-slot:modal-footer>
        <b-button variant="secondary" @click="$bvModal.hide('modal-auth')"
          >キャンセル</b-button
        >
        <b-button
          variant="primary"
          @click="
            $bvModal.hide('modal-auth');
            $bvModal.show('modal-registration');
          "
          >新規登録</b-button
        >
        <b-button variant="primary" @click="login">ログイン</b-button>
      </template>
    </b-modal>
  </div>
</template>

<script>
import axios from "axios";
const api = axios.create({
  baseURL: 'http://localhost:4567/api/v1',
  headers: {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  },
  responseType: 'json'
})
export default {
  name: "AuthModal",
  data() {
    return {
      user: {
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        shared_key: ""
      }
    }
  },
  methods: {
    registration: function () {
      api.post("/users", {
        name: this.user.name,
        email: this.user.email,
        password: this.user.password,
        password_confirmation: this.user.password_confirmation,
        shared_key: this.user.shared_key
      })
        .then((response) => {
          if (response.status != 200) return

          this.$store.commit("setUserState", {
            userState: {
              id: response.data.id,
              token: response.data.token,
              refresh_token: response.data.refresh_token
            }
          })

          this.$bvModal.hide("modal-registration")

          this.$router.push({
            path: "/result"
          })
        })
    },
    login: function () {
      api.post("/session", {
        email: this.user.email,
        password: this.user.password
      })
        .then((response) => {
          if (response.status != 200) return

          this.$store.commit("setUserState", {
            userState: {
              id: response.data.id,
              token: response.data.token,
              refresh_token: response.data.refresh_token
            }
          })

          this.$bvModal.hide("modal-auth")

          this.$router.push({
            path: "/result"
          })
        })
    }
  }
}
</script>
