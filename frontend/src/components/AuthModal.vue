<template>
  <div class="component-authmodal">
    <b-form @submit.prevent="registration" id="registration">
      <b-modal id="modal-registration" title="ユーザー登録" size="lg" centered>
        <b-form-input
          v-model="user.name"
          type="text"
          name="name"
          ref="reg_name"
          placeholder="名前"
          @keyup.enter="$refs.reg_email.focus()"
        ></b-form-input>
        <b-form-input
          v-model="user.email"
          type="email"
          name="email"
          ref="reg_email"
          placeholder="メールアドレス"
          @keyup.enter="$refs.reg_password.focus()"
        ></b-form-input>
        <b-form-input
          v-model="user.password"
          type="password"
          name="password"
          ref="reg_password"
          placeholder="パスワード(6文字以上24文字以内)"
          @keyup.enter="$refs.reg_password_confirmation.focus()"
        ></b-form-input>
        <b-form-input
          v-model="user.password_confirmation"
          type="password"
          name="password_confirmation"
          ref="reg_password_confirmation"
          placeholder="パスワード(確認)"
          @keyup.enter="$refs.reg_shared_key.focus()"
        ></b-form-input>
        <b-form-input
          v-model="user.shared_key"
          type="text"
          name="shared_key"
          ref="reg_shared_key"
          placeholder="事前共有キー"
          @keyup.enter="registration"
        ></b-form-input>
        <template v-slot:modal-footer>
          <b-button
            variant="secondary"
            @click="$bvModal.hide('modal-registration')"
            >キャンセル</b-button
          >
          <b-button variant="primary" type="submit" form="registration"
            >登録</b-button
          >
        </template>
      </b-modal>
    </b-form>

    <b-form @submit.prevent="login" id="login">
      <b-modal id="modal-auth" title="ユーザー認証" size="lg" centered>
        <b-form-input
          v-model="user.email"
          type="email"
          name="email"
          ref="login_email"
          placeholder="メールアドレス"
          @keyup.enter="$refs.login_password.focus()"
        ></b-form-input>
        <b-form-input
          v-model="user.password"
          type="password"
          name="password"
          ref="login_password"
          placeholder="パスワード"
          @keyup.enter="login"
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
          <b-button variant="primary" type="submit" form="login"
            >ログイン</b-button
          >
        </template>
      </b-modal>
    </b-form>
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
    registration: async function () {
      const response = await api.post("/users", {
        name: this.user.name,
        email: this.user.email,
        password: this.user.password,
        password_confirmation: this.user.password_confirmation,
        shared_key: this.user.shared_key
      })
        .catch(error => error.response)

      console.log(response);
      if (response.status != 200) return

      this.$store.commit("setUserState", {
        userState: {
          id: response.data.id,
          token: response.data.token,
          refresh_token: response.data.refresh_token
        }
      })

      this.$bvModal.hide('modal-registration')

      this.$router.push({
        path: "/result"
      })
    },
    login: async function () {
      const response = await api.post("/sessions", {
        email: this.user.email,
        password: this.user.password
      })
        .catch(error => error.response)

      console.log(response);
      if (response.status != 200) return

      this.$store.commit("setUserState", {
        userState: {
          id: response.data.id,
          token: response.data.token,
          refresh_token: response.data.refresh_token
        }
      })

      this.$bvModal.hide('modal-auth')

      this.$router.push({
        path: "/result"
      })
    }
  }
}
</script>
