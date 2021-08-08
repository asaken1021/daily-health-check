<template>
  <div class="container component-resultlist">
    <b-form>
      <b-form-group id="input-group-date" label="日付:" label-for="input-date">
        <b-form-datepicker
          id="input-date"
          v-model="form.selectedDate"
          @input="getResults"
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
          @change="getResults"
          required
        ></b-form-select>
      </b-form-group>
    </b-form>

    <b-table
      striped
      hover
      :items="results"
      :fields="options.fields"
      :tbody-tr-class="setRowColor"
      @row-clicked="showResultDetail"
    >
    </b-table>

    <b-modal id="modal-result_detail" title="調査結果詳細" size="lg" centered>
      <b-table
        stacked
        :items="resultDetail.result"
        :fields="resultDetail.fields"
      ></b-table>
      <template v-slot:modal-footer>
        <b-button
          variant="primary"
          @click="$bvModal.hide('modal-result_detail')"
          >閉じる</b-button
        >
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
  name: "ResultList",
  data() {
    return {
      form: {
        selectedDate: null,
        selectedClass: null
      },
      options: {
        classes: [],
        fields: [
          {
            key: "student.class_number",
            label: "出席番号",
            sortable: true
          },
          {
            key: "student.name",
            label: "名前",
            sortable: false
          },
          {
            key: "result.temperature",
            label: "体温",
            sortable: true
          },
          {
            key: "result.condition",
            label: "体調",
            sortable: true
          }
        ]
      },
      resultDetail: {
        result: [],
        fields: [
          {
            key: "student.class_number",
            label: "出席番号"
          },
          {
            key: "student.name",
            label: "名前"
          },
          {
            key: "result.temperature",
            label: "体温"
          },
          {
            key: "result.condition",
            label: "体調"
          },
          {
            key: "result.symptom",
            label: "症状"
          }
        ]
      },
      results: []
    }
  },
  async mounted() {
    this.$nextTick(function () {
      api.interceptors.response.use(response => { console.log("api interceptors called"); return response }, async error => {
        console.log("error", error);
        if (error.response.status == 401 && !error.config.isRetried) {
          console.log("token refresh called");
          const response = await api.put("/sessions", {
            refresh_token: this.$store.getters.getUserState.refresh_token
          })
            .catch(error => error.response)

          error.config.isRetried = true;

          if (response.status != 200) {
            console.log("token refresh error");
            return
          }

          this.$store.commit("setUserState", {
            userState: {
              id: response.data.id,
              token: response.data.token,
              refresh_token: response.data.refresh_token
            }
          })

          const params = error.config.params;
          params.token = this.$store.getters.getUserState.token;
          error.config.params = params;

          return api(error.config);
        }
      })
    });

    console.log("ResultList mounted called");
    const response = await api.get("/classes", {
      params: {
        token: this.$store.getters.getUserState.token
      }
    })
      .catch(error => error.response)

    console.log(response);
    if (response.status != 200) return

    for (let da of response.data) {
      this.options.classes.push(da.name);
    }
  },
  methods: {
    getResults: async function () {
      console.log("ResultList getResults called");
      if (this.form.selectedDate == null || this.form.selectedClass == null) return

      const response = await api.get("/results", {
        params: {
          token: this.$store.getters.getUserState.token,
          class_name: this.form.selectedClass,
          date: this.form.selectedDate
        }
      })
        .catch(error => error.response)

      console.log(response);
      if (response.status != 200) return

      this.results = response.data.results;
    },
    setRowColor: function (item, type) {
      if (!item || type != "row") return
      if (item.result.temperature >= 37.5) return "table-warning"
    },
    showResultDetail: function (data) {
      console.log("showResultData called", data);
      this.resultDetail.result = [data];
      this.$bvModal.show('modal-result_detail')
    }
  }
}
</script>
