require "bundler/setup"
Bundler.setup
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/namespace"
require "./database"

configure do
  self.instance_eval do
    undef :namespace

    define_singleton_method(:namespace) do |*args, &block|
      Sinatra::Delegator.target.send(:namespace, *args, &block)
    end
  end
end

def bad_request
  status 400
  res_data = {
    error: 'Bad Request'
  }

  return json res_data
end

def unauthorized
  status 401
  res_data = {
    error: 'Unauthorized'
  }

  return json res_data
end

def forbidden
  status 403
  res_data = {
    error: 'Forbidden'
  }

  return json res_data
end

def not_found
  status 404
  res_data = {
    error: 'Not Found'
  }

  return json res_data
end

options '*' do
  response.headers["Access-Control-Allow-Methods"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Origin"] = "http://localhost:8080"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, X-Requested-With"
  response.headers["Access-Control-Allow-Credentials"] = "true"
end

before do
  response.headers["Access-Control-Allow-Origin"] = "http://localhost:8080"
  response.headers["Access-Control-Allow-Credentials"] = "true"
end

namespace '/api' do
  get '/' do
    status 200
    res_data = {
      Example: "example data"
    }

    json res_data
  end
end