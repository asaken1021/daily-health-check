<template>
  <div class="component-settingitems">
    <b-card
      title="登録用CSVファイルのアップロード "
      class="text-center col"
    ></b-card>

    <b-form @submit.prevent="upload" id="manage">
      <b-modal
        id="modal-manage"
        title="登録用CSVファイルのアップロード"
        size="lg"
        centered
      >
        <b-form-file
          v-model="file"
          placeholder="ファイルを選択..."
          accept=".csv"
        ></b-form-file>
        <template v-slot:modal-footer>
          <b-button variant="secondary" @click="$bvModal.hide('modal-manage')"
            >キャンセル</b-button
          >
          <b-button variant="primary" type="submit" form="manage"
            >送信</b-button
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
});

export default {
  name: "SettingItems",
  data() {
    return {
      file: null
    }
  },
  async mounted() {
    console.log("SettingItems mounted called");
  },
  methods: {
    upload: async function () {
      const params = new FormData();
      params.append('file', this.file);

      const response = await api.post("/manage", params, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }).catch(error => error.response)

      console.log(response);
    }
  }
}
</script>
