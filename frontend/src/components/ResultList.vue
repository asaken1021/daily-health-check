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

    <b-table
      striped
      :items="results"
      :fields="options.fields"
      :tbody-tr-class="setRowColor"
    >
      <template #cell(name)="data">{{ searchName(data) }}</template>
      <template #cell(temperature)="data">{{
        setTemperatureText(data)
      }}</template>
      <template #cell(condition)="data">{{ setConditionText(data) }}</template>
    </b-table>
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
        classes: [],
        fields: [
          {
            key: "class_number",
            label: "出席番号",
            sortable: true
          },
          {
            key: "name",
            label: "名前",
            sortable: false
          },
          {
            key: "temperature",
            label: "体温",
            sortable: true
          },
          {
            key: "condition",
            label: "体調",
            sortable: true
          }
        ]
      },
      results: [],
      nameTable: []
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
      api.get("/result", {
        params: {
          date: this.form.selectedDate,
          class_name: this.form.selectedClass
        }
      })
        .then(response => {
          if (response.status == 200) {
            console.log(response);
            this.results = response.data;
          }
        })
      api.get("/students", {
        params: {
          class_name: this.form.selectedClass
        }
      })
        .then(response => {
          if (response.status == 200) {
            console.log(response);
            this.nameTable = response.data.students
          }
        })
    },
    searchName: function (data) {
      console.log(data);
      try {
        return this.nameTable.filter(student => student.class_number == data.item.class_number)[0].name
      } catch (error) {
        return "Undefined"
      }
    },
    setRowColor: function (item, type) {
      if (!item || type != "row") return
      if (item.temperature >= 37.5) return "table-warning"
    },
    setTemperatureText: function (data) {
      return Number.parseFloat(data.item.temperature).toFixed(1)
    },
    setConditionText: function (data) {
      if (data.item.condition == "\"good\"") return "体調は良い"
      else if (data.item.condition == "\"not_good\"") return "少し体調が悪い"
      else if (data.item.condition == "\"bad\"") return "体調は悪い"
    }
  }
}
</script>
