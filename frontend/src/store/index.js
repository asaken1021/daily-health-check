import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    userState: {
      id: 0,
      token: "",
      refresh_token: ""
    }
  },
  getters: {
    getUserState(state) {
      return state.userState;
    }
  },
  mutations: {
    setUserState(state, payload) {
      state.userState = payload.userState;
    }
  }
})

export default store
