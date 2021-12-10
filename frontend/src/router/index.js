import Vue from 'vue'
import VueRouter from 'vue-router'
import BootstrapVue from 'bootstrap-vue'
import Main from '../views/Main.vue'
import Survey from '../views/Survey.vue'
import Result from '../views/Result.vue'
import Settings from '../views/Settings.vue'

Vue.use(VueRouter)
Vue.use(BootstrapVue)

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

const routes = [
  {
    path: '/',
    name: 'Main',
    component: Main
  },
  {
    path: '/survey',
    name: 'Survey',
    component: Survey
  },
  {
    path: '/result',
    name: 'Result',
    component: Result
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL, routes
})

export default router
