<template>
  <div class="container component-surveyitems">
    <b-form>
      <b-form-group
        id="input-group-class"
        label="クラス:"
        label-for="input-class"
      >
        <b-form-select
          id="input-class"
          v-model="form.selectedClass"
          :options="options.classes"
          @change="getName"
          required
        ></b-form-select>
      </b-form-group>

      <b-form-group
        id="input-group-number"
        label="出席番号:"
        label-for="input-number"
      >
        <b-form-input
          id="input-number"
          v-model="form.number"
          @change="getName"
          required
        ></b-form-input>
      </b-form-group>

      <b-form-group
        id="input-group-name"
        label="名前(自動入力):"
        label-for="input-name"
      >
        <b-form-input
          id="input-name"
          v-model="form.name"
          disabled
        ></b-form-input>
      </b-form-group>

      <b-form-group
        id="input-group-temperature"
        label="体温:"
        label-for="input-temperature"
      >
        <b-form-input
          id="input-temperature"
          v-model="form.temperature"
          required
        ></b-form-input>
      </b-form-group>

      <b-form-group
        id="input-group-condition"
        label="体調:"
        label-for="input-condition"
      >
        <b-form-radio-group
          id="input-condition"
          v-model="form.condition"
          :options="options.condition"
          stacked
          required
        ></b-form-radio-group>
      </b-form-group>

      <b-form-group
        id="input-group-symptom"
        label="症状の詳細:"
        label-for="input-symptom"
      >
        <b-form-checkbox-group
          id="input-symptom"
          v-model="form.symptom"
          :options="options.symptom"
          stacked
        >
        </b-form-checkbox-group>
      </b-form-group>
    </b-form>

    <b-button id="button-send" variant="primary" v-on:click="sendForm"
      >送信</b-button
    >
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
});

export default {
  name: "SurveyItems",
  data() {
    return {
      form: {
        selectedClass: "",
        number: null,
        name: "",
        temperature: null,
        condition: null,
        symptom: []
      },
      options: {
        classes: [],
        condition: [
          { text: "体調は良い", value: "good" },
          { text: "いつもと違い体調が悪い気がする (自宅で学習もしくは療養してください)", value: "not_good" },
          { text: "とても体調が悪い (自宅で療養してください)", value: "bad" }
        ],
        symptom: [
          { text: "咳・くしゃみが出る", value: "cough" },
          { text: "喉が痛い", value: "throat" },
          { text: "腹痛", value: "stomachache" },
          { text: "下痢", value: "diarrhea" },
          { text: "嘔吐", value: "vomit" },
          { text: "頭痛", value: "headache" },
          { text: "発熱・悪寒", value: "ferver" },
          { text: "息切れ・呼吸困難", value: "dyspnea" },
          { text: "味覚・嗅覚障害", value: "dysgeusia" },
          { text: "筋肉痛・倦怠感", value: "malaise" }
        ]
      }
    }
  },
  mounted() {
    console.log("SurveyItems mounted nextTick called");
    api.get("/class")
      .then(response => {
        if (response.status != 200) return

        console.log(response);
        for (var da of response.data) {
          this.options.classes.push(da.class_name);
        }
      });
  },
  methods: {
    getName: function () {
      console.log("getName called");
      api.get("/student", {
        params: {
          class_name: this.form.selectedClass,
          class_number: this.form.number
        }
      })
        .then(response => {
          if (response.status != 200) return

          console.log(response);
          this.form.name = response.data.student.name;
        })
        .catch(error => {
          console.log(error);
          this.form.name = error.message;
        })
    },
    sendForm: function () {
      console.log("sendForm called");
      api.post("/result", {
        class_name: this.form.selectedClass,
        class_number: this.form.number,
        temperature: this.form.temperature,
        condition: this.form.condition,
        symptom: this.form.symptom
      })
    }
  }
}
</script>
