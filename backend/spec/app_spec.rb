# require './app/app'

RSpec.describe "/api" do
  describe "GET /api" do
    before :all do
      get '/api/'
      @body = JSON.parse(last_response.body)
    end

    example("response is ok") {expect(last_response).to be_ok}
    example("data is 'example data'") {expect(@body["Example"]).to eq "example data"}
  end
end