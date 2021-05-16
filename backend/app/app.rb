require "bundler/setup"
Bundler.setup
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/namespace"
require "rack/contrib"
require "date"
require "./database"

# use Rack::JSONBodyParser

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
  namespace '/v1' do
    get '/' do
      status 200
      res_data = {
        Example: "example data"
      }

      json res_data
    end

    get '/result' do
      if params[:test] == "true"
        results = Result.where(student_id: params[:student_id])
        res_data = results.last
      else
        results = Result.where(created_at: params[:date].in_time_zone.all_day)
        res_data = results
      end

      json res_data
    end

    post '/result' do
      req_data = JSON.parse(request.body.read)

      result = Result.create(
        student_id: req_data["student_id"],
        temperature: req_data["temperature"],
        condition: req_data["condition"].to_json,
        symptom: req_data["symptom"].to_json
      )

      return bad_request if !result.persisted?

      status 200
      res_data = {
        response: "OK"
      }

      json res_data
    end

    get '/class' do
      res_data = ClassName.all
      json res_data
    end

    post '/class' do
      req_data = JSON.parse(request.body.read)

      ClassName.create(
        class_name: req_data["name"]
      )

      status 200
      res_data = {
        response: "OK"
      }

      json res_data
    end

    get '/student' do
      return bad_request if params[:class_name] == nil || params[:class_number] == nil
      student = Student.find_by(class_name: params[:class_name], class_number: params[:class_number])

      return not_found if student == nil

      status 200
      res_data = {
        response: "OK",
        student: student
      }

      json res_data
    end

    post '/student' do
      req_data = JSON.parse(request.body.read)

      Student.create(
        class_name: req_data["class_name"],
        class_number: req_data["class_number"],
        name: req_data["name"]
      )

      status 200
      res_data = {
        response: "OK"
      }

      json res_data
    end
  end
end