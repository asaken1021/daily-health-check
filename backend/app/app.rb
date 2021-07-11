require "bundler/setup"
Bundler.setup
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/namespace"
require "rack/contrib"
require "date"
require "./database"
require "jwt"

# use Rack::JSONBodyParser

configure do
  self.instance_eval do
    undef :namespace

    define_singleton_method(:namespace) do |*args, &block|
      Sinatra::Delegator.target.send(:namespace, *args, &block)
    end
  end
end

privkey = OpenSSL::PKey::RSA.generate(2048)
pubkey = privkey.public_key

refresh_privkey = OpenSSL::PKey::RSA.generate(2048)
refresh_pubkey = refresh_privkey.public_key

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

def JWTencode(payload, privkey)
  return JWT.encode(payload, privkey, 'RS256')
end

def JWTdecode(token, pubkey)
  return JWT.decode(token, pubkey, true, { algorithm: 'RS256' })[0]
end

def token_check(token, pubkey)
  JWT.decode(token, pubkey, true, { algorithm: 'RS256' })
  return true
rescue => e
  return false
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
    req_data = nil

    before do
      req_plain = request.body.read
      if req_plain == ""
        req_data = JSON.parse("{}")
      else
        req_data = JSON.parse(req_plain)
      end

      if @env["REQUEST_METHOD"] != "OPTIONS"
        if params["token"] != nil
          return halt unauthorized if !token_check(params["token"], pubkey)
        elsif req_data["token"] != nil
          return halt unauthorized if !token_check(req_data["token"], pubkey)
        end
      end
    end

    get '/' do
      status 200
      res_data = {
        Example: "example data"
      }

      json res_data
    end

    get '/result' do
      if params[:test] == "true"
        results = Result.where(class_number: params[:class_number])
        res_data = results.last
      else
        token = params["token"]
        return bad_request if token == nil

        user_id = JWTdecode(token, pubkey)["id"]
        return bad_request if user_id == nil

        user = User.find_by(id: user_id)
        return unauthorized if user == nil

        results = Result.where(created_at: params[:date].in_time_zone.all_day, class_name: params[:class_name])
        res_data = results
      end

      json res_data
    end

    post '/result' do
      # req_data = JSON.parse(request.body.read)

      result = Result.create(
        class_name: req_data["class_name"],
        class_number: req_data["class_number"],
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
      # token = params["token"]
      # return bad_request if token == nil

      # user_id = JWTdecode(token, pubkey)["id"]
      # return bad_request if user_id == nil

      # user = User.find_by(id: user_id)
      # return unauthorized if user == nil

      res_data = ClassName.all
      json res_data
    end

    post '/class' do
      # req_data = JSON.parse(request.body.read)

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
      # token = params["token"]
      # return bad_request if token == nil

      # user_id = JWTdecode(token, pubkey)["id"]
      # return bad_request if user_id == nil

      # user = User.find_by(id: user_id)
      # return unauthorized if user == nil

      # return bad_request if params[:class_name] == nil || params[:class_number] == nil
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
      # req_data = JSON.parse(request.body.read)

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

    get '/students' do
      token = params["token"]
      return bad_request if token == nil

      user_id = JWTdecode(token, pubkey)["id"]
      return bad_request if user_id == nil

      user = User.find_by(id: user_id)
      return unauthorized if user == nil

      return bad_request if params[:class_name] == nil
      students = Student.where(class_name: params[:class_name])

      return not_found if students == nil

      status 200
      res_data = {
        response: "OK",
        students: students
      }

      json res_data
    end

    post '/keys' do
      shared_key = Shared_Keys.create(
        key: req_data["key"]
      )

      return bad_request if !shared_key.persisted?

      status 200

      res_data = {
        response: "OK"
      }

      json res_data
    end

    post '/users' do
      # req_data = JSON.parse(request.body.read)
      return bad_request if Shared_Keys.find_by(key: req_data["shared_key"]) == nil

      user = User.create(
        name: req_data["name"],
        email: req_data["email"],
        password: req_data["password"],
        password_confirmation: req_data["password_confirmation"]
      )
      return bad_request if !user.persisted?

      status 200

      payload = {
        id: user.id,
        exp: Time.now.to_i + 12
      }
      refresh_payload = {
        id: user.id,
        exp: Time.now.to_i + 3600
      }

      token = JWTencode(payload, privkey)
      refresh_token = JWTencode(refresh_payload, refresh_privkey)

      res_data = {
        id: user.id,
        token: token,
        refresh_token: refresh_token
      }

      json res_data
    end

    post '/session' do
      user = User.find_by(email: req_data["email"])
      return bad_request if user == nil
      return bad_request if !user.authenticate(req_data["password"])

      status 200
      payload = {
        id: user.id,
        exp: Time.now.to_i + 12
      }
      refresh_payload = {
        id: user.id,
        exp: Time.now.to_i + 3600
      }

      token = JWTencode(payload, privkey)
      refresh_token = JWTencode(refresh_payload, refresh_privkey)

      res_data = {
        id: user.id,
        token: token,
        refresh_token: refresh_token
      }

      json res_data
    end

    put "/session" do
      refresh_token = req_data["refresh_token"]
      return bad_request if refresh_token == nil

      user_id = JWTdecode(refresh_token, refresh_pubkey)["id"]
      return bad_request if user_id == nil

      user = User.find_by(id: user_id)
      return unauthorized if user == nil

      payload = {
        id: user.id,
        exp: Time.now.to_i + 12
      }
      refresh_payload = {
        id: user.id,
        exp: Time.now.to_i + 3600
      }

      token = JWTencode(payload, privkey)
      refresh_token = JWTencode(refresh_payload, refresh_privkey)

      res_data = {
        id: user.id,
        token: token,
        refresh_token: refresh_token
      }

      json res_data
    end
  end
end
