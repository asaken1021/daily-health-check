require_relative '../app/app'

RSpec.describe 'helloworld' do
  it 'msg' do
    expect(Main.new.msg).to eq 'Hello, world!'
  end
end
