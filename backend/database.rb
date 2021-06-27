require "bundler/setup"
Bundler.require

ActiveRecord::Base.establish_connection("sqlite3:db/database.db")

class Student < ActiveRecord::Base

end

class Result < ActiveRecord::Base
  validates :temperature,
    presence: true
  validates :condition,
    presence: true
  validates :symptom,
    presence: true
end

class ClassName < ActiveRecord::Base

end

class User < ActiveRecord::Base
  has_secure_password
  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password,
    presence: true,
    length: { in: 6..24 }
end

class Shared_Keys < ActiveRecord::Base
  validates :key,
    presence: true
end
