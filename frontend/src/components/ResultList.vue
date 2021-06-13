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
            key: "conditionText",
            label: "体調",
            sortable: true
          }
        ]
      },
      resultDetail: {
        result: [],
        fields: [
          {
            key: "class_number",
            label: "出席番号"
          },
          {
            key: "name",
            label: "名前"
          },
          {
            key: "temperature",
            label: "体温"
          },
          {
            key: "conditionText",
            label: "体調"
          },
          {
            key: "symptomText",
            label: "症状"
          }
        ]
      },
      results: [],
      nameTable: []
    }
  },
  mounted() {
    console.log("ResultList mounted called");
    api.get("/class")
      .then(response => {
        if (response.status != 200) return

        console.log("class", response);
        for (let da of response.data) {
          this.options.classes.push(da.class_name);
        }
      })
  },
  methods: {
    getResults: async function () {
      console.log("ResultList getResults called");
      await api.get("/students", {
        params: {
          class_name: this.form.selectedClass
        }
      })
        .then(response => {
          if (response.status != 200) return

          console.log("nameTable", response);
          this.nameTable = response.data.students
        })
      api.get("/result", {
        params: {
          date: this.form.selectedDate,
          class_name: this.form.selectedClass
        }
      })
        .then(response => {
          if (response.status != 200) return

          console.log("results", response);
          this.results = [];
          for (let da of response.data) {
            try {
              da.name = this.nameTable.filter(student => student.class_number == da.class_number)[0].name
            } catch (error) {
              console.log("An error occurred:", da, error);
              if (error.name == "TypeError") da.name = "Error: Name not found"
              else da.name = "Error: " + error.name
            }

            da.temperature = Number.parseFloat(da.temperature).toFixed(1);

            if (JSON.parse(da.condition) == "good") da.conditionText = "体調は良い"
            if (JSON.parse(da.condition) == "not_good") da.conditionText = "少し体調が悪い"
            if (JSON.parse(da.condition) == "bad") da.conditionText = "体調が悪い"

            da.symptomText = this.setSymptomText(da.symptom);

            console.log("da", da);

            this.results.push(da);
          }
        })
    },
    setRowColor: function (item, type) {
      if (!item || type != "row") return
      if (item.temperature >= 37.5) return "table-warning"
    },
    setSymptomText: function (data) {
      const tmp = JSON.parse(data).toString();
      let tmp2 = [];

      console.log("tmp", tmp);

      if (tmp.includes("cough")) tmp2.push("咳・くしゃみが出る");
      if (tmp.includes("throat")) tmp2.push("喉が痛い");
      if (tmp.includes("stomachache")) tmp2.push("腹痛");
      if (tmp.includes("diarrhea")) tmp2.push("下痢");
      if (tmp.includes("vomit")) tmp2.push("嘔吐");
      if (tmp.includes("headache")) tmp2.push("頭痛");
      if (tmp.includes("fever")) tmp2.push("発熱・悪寒");
      if (tmp.includes("dyspnea")) tmp2.push("息切れ・呼吸困難");
      if (tmp.includes("dysgeusia")) tmp2.push("味覚・嗅覚障害");
      if (tmp.includes("malaise")) tmp2.push("筋肉痛・倦怠感");

      console.log("tmp2", tmp2);
      return tmp2.toString();
    },
    showResultDetail: function (data) {
      this.resultDetail.result = [data];
      this.$bvModal.show('modal-result_detail')
    }
  }
}
</script>
