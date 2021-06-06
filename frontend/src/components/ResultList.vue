<template>
  <div class="container component-resultlist">
    <b-form>
      <b-form-group id="input-group-date" label="日付:" label-for="input-date">
        <b-form-datepicker
          id="input-date"
          v-model="form.selectedDate"
          v-on:input="getResults"
          required
        ></b-form-datepicker>
      </b-form-group>

      <b-form-group
        id="input-group-class"
        label="クラス:"
        label-for="input-class"
      >
        <b-form-select
          id="input-class"
          v-model="form.selectedClass"
          :options="options.classes"
          v-on:change="getResults"
          required
        ></b-form-select>
      </b-form-group>
    </b-form>

    <span>{{ results }}</span>
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
  name: "ResultList",
  data() {
    return {
      form: {
        selectedDate: "",
        selectedClass: ""
      },
      options: {
        classes: []
      },
      results: []
    }
  },
  mounted() {
    this.$nextTick(function () {
      console.log("ResultList mounted nextTick called");
      api.get("/class")
        .then(response => {
          if (response.status == 200) {
            console.log(response);
            for (var da of response.data) {
              this.options.classes.push(da.class_name);
            }
          }
        })
    })
  },
  methods: {
    getResults: function () {
      console.log("ResultList getResults called");
      api.get("result", {
        params: {
          date: this.form.selectedDate,
          class: this.form.selectedClass
        }
      })
        .then(response => {
          if (response.status == 200) {
            console.log(response);
            this.results = response.data;
          }
        })
    }
  }
}
</script>
