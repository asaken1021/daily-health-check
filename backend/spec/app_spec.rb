# require './app/app'

RSpec.describe "/api/v1" do
  describe "GET /api/v1/" do
    before :all do
      get '/api/v1/'
      @body = JSON.parse(last_response.body)
    end

    example("response is ok") {expect(last_response).to be_ok}
    example("data is 'example data'") {expect(@body["Example"]).to eq "example data"}
  end

  describe "POST /api/v1/result" do
    before :all do
      params = {
        student_id: 5000,
        temperature: 36.5,
        condition: {
          healthy: true,
          sickness: false
        },
        symptom: {
          cough: false,
          headache: false,
          stomachache: false
       }
      }.to_json
      post '/api/v1/result', params#, as: :json
      @body = JSON.parse(last_response.body)
    end

    example("response is ok") {expect(last_response).to be_ok}
    example("data is 'OK'") {expect(@body["response"]).to eq "OK"}
  end

  describe "GET /api/v1/result?test=true&student_id=5000" do
    before :all do
      get '/api/v1/result?test=true&student_id=5000'
      @body = JSON.parse(last_response.body)
      @condition = JSON.parse(@body["condition"])
      @symptom = JSON.parse(@body["symptom"])
    end

    example("response is ok") {expect(last_response).to be_ok}
    example("data is exact data") {
      expect(@body["student_id"]).to eq 5000
      expect(@body["temperature"]).to eq 36.5
      expect(@condition["healthy"]).to eq true
      expect(@condition["sickness"]).to eq false
      expect(@symptom["cough"]).to eq false
      expect(@symptom["headache"]).to eq false
      expect(@symptom["stomachache"]).to eq false
    }
  end
end