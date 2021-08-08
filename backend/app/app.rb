require "bundler/setup"
Bundler.setup
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/namespace"
require "rack/contrib"
require "date"
require "./database"
require "jwt"

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

def jwt_encode(payload, privkey)
  return JWT.encode(payload, privkey, 'RS256')
end

def jwt_decode(token, pubkey)
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
  namespace '/dev' do
    get '/bind' do
      binding.pry
    end
  end
  namespace '/v1' do
    req_data = nil

    before do
      req_plain = request.body.read
      if req_plain.empty?
        req_data = {}
      else
        req_data = JSON.parse(req_plain)
      end

      if @env["REQUEST_METHOD"] != "OPTIONS"
        return halt unauthorized if !params["token"].nil? && !token_check(params["token"], pubkey)
        return halt unauthorized if !req_data["token"].nil? && !token_check(req_data["token"], pubkey)
      end
    end

    get '/' do
      status 200
      res_data = {
        Example: "example data"
      }

      json res_data
    end

    get '/results' do
      token = params["token"]
       return bad_request if token.nil?

      user_id = jwt_decode(token, pubkey)["id"]
      return bad_request if user_id.nil?

      user = User.find(user_id)
      return unauthorized if user.nil?

      class_id = ClassName.find_by(name: params[:class_name]).id
      # stu_cl = StudentClassName.where(class_id: class_id)
      res_cl = ResultClassName.where(class_id: class_id, created_at: params[:date].in_time_zone.all_day)
      result_tmp = nil
      result_tmp_symp = nil
      symptomText = []
      results = []
      # students = []

      # stu_cl.each do |sc|
      #   students.push(sc.student)
      # end
      res_cl.each do |rc|
        result_tmp = rc.result
        result_tmp_symp = JSON.parse(rc.result.symptom)

        result_tmp.condition = "体調は良い" if result_tmp.condition == "good"
        result_tmp.condition = "少し体調が悪い" if result_tmp.condition == "not_good"
        result_tmp.condition = "体調が悪い" if result_tmp.condition == "bad"

        result_tmp_symp.map!{|x| x == "cough" ? "咳・くしゃみが出る" : x}
        result_tmp_symp.map!{|x| x == "throat" ? "喉が痛い" : x}
        result_tmp_symp.map!{|x| x == "stomachache" ? "腹痛" : x}
        result_tmp_symp.map!{|x| x == "diarrhea" ? "下痢" : x}
        result_tmp_symp.map!{|x| x == "vomit" ? "嘔吐" : x}
        result_tmp_symp.map!{|x| x == "headache" ? "頭痛" : x}
        result_tmp_symp.map!{|x| x == "fever" ? "発熱・悪寒" : x}
        result_tmp_symp.map!{|x| x == "dyspnea" ? "息切れ・呼吸困難" : x}
        result_tmp_symp.map!{|x| x == "dysgeusia" ? "味覚・嗅覚障害" : x}
        result_tmp_symp.map!{|x| x == "malaise" ? "筋肉痛・倦怠感" : x}

        result_tmp.symptom = result_tmp_symp.join(", ")

        results.push(
          result: result_tmp,
          student: rc.result.student_results.first.student
        )
      end

      res_data = {
        # students: students,
        results: results
      }

      json res_data
    end

    post '/results' do
      student_id = req_data["student_id"]
      class_id = ClassName.find_by(name: req_data["class_name"]).id

      return bad_request if class_id.nil?

      result = Result.create(
        temperature: req_data["temperature"],
        condition: req_data["condition"],
        symptom: req_data["symptom"]
      )

      return bad_request if !result.persisted?

      ResultClassName.create(
        result_id: result.id,
        class_id: class_id
      )
      StudentResult.create(
        student_id: student_id,
        result_id: result.id
      )

      status 200
      res_data = {
        response: "OK"
      }

      json res_data
    end

    get '/classes' do
      res_data = ClassName.all
      json res_data
    end

    post '/classes' do
      ClassName.create(
        name: req_data["name"]
      )

      status 200
      res_data = {
        response: "OK"
      }

      json res_data
    end

    post '/students' do
      class_id = ClassName.find_by(name: req_data["class_name"]).id
      student = Student.create(
        class_number: req_data["class_number"],
        name: req_data["name"]
      )
      StudentClassName.create(
        student_id: student.id,
        class_id: class_id
      )

      status 200
      res_data = {
        response: "OK"
      }

      json res_data
    end

    get '/student' do
      return bad_request if params[:class_name].nil? || params[:class_number].nil?
      class_id = ClassName.find_by(name: params[:class_name])
      stu_cl = StudentClassName.where(class_id: class_id)
      student = nil

      stu_cl.each do |sc|
        student = sc.student if sc.student.class_number.to_s == params[:class_number]
      end

      return not_found if student.nil?

      status 200
      res_data = {
        response: "OK",
        student: student
      }

      json res_data
    end

    get '/students' do
      token = params["token"]
      return bad_request if token.nil?

      user_id = jwt_decode(token, pubkey)["id"]
      return bad_request if user_id.nil?

      user = User.find(user_id)
      return unauthorized if user.nil?

      return bad_request if params[:class_name].nil?
      class_id = ClassName.find_by(name: params[:class_name])
      stu_cl = StudentClassName.where(class_id: class_id)
      students = []

      stu_cl.each do |sc|
        students.push(sc.student)
      end

      return not_found if students.nil?

      status 200
      res_data = {
        response: "OK",
        students: students
      }

      json res_data
    end

    post '/keys' do
      shared_key = SharedKey.create(
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
      return bad_request if SharedKey.find_by(key: req_data["shared_key"]).nil?

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

      token = jwt_encode(payload, privkey)
      refresh_token = jwt_encode(refresh_payload, refresh_privkey)

      res_data = {
        id: user.id,
        token: token,
        refresh_token: refresh_token
      }

      json res_data
    end

    post '/sessions' do
      user = User.find_by(email: req_data["email"])
      return bad_request if user.nil?
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

      token = jwt_encode(payload, privkey)
      refresh_token = jwt_encode(refresh_payload, refresh_privkey)

      res_data = {
        id: user.id,
        token: token,
        refresh_token: refresh_token
      }

      json res_data
    end

    put "/sessions" do
      refresh_token = req_data["refresh_token"]
      return bad_request if refresh_token.nil?

      user_id = jwt_decode(refresh_token, refresh_pubkey)["id"]
      return bad_request if user_id.nil?

      user = User.find(user_id)
      return unauthorized if user.nil?

      payload = {
        id: user.id,
        exp: Time.now.to_i + 12
      }
      refresh_payload = {
        id: user.id,
        exp: Time.now.to_i + 3600
      }

      token = jwt_encode(payload, privkey)
      refresh_token = jwt_encode(refresh_payload, refresh_privkey)

      res_data = {
        id: user.id,
        token: token,
        refresh_token: refresh_token
      }

      json res_data
    end
  end
end
