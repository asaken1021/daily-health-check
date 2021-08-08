require "bundler/setup"
Bundler.require

ActiveRecord::Base.establish_connection("sqlite3:db/database.db")

class Student < ActiveRecord::Base
  has_many :student_class_names
  has_many :student_results
end

class Result < ActiveRecord::Base
  has_many :student_results
  has_many :result_class_names
  validates :temperature,
    presence: true
  validates :condition,
    presence: true
  validates :symptom,
    presence: true
end

class ClassName < ActiveRecord::Base
  has_many :student_class_names
  has_many :result_class_names
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

class SharedKey < ActiveRecord::Base
  validates :key,
    presence: true
end

class StudentClassName < ActiveRecord::Base
  belongs_to :student
  belongs_to :class_name
end

class ResultClassName < ActiveRecord::Base
  belongs_to :result
  belongs_to :class_name
end

class StudentResult < ActiveRecord::Base
  belongs_to :student
  belongs_to :result
end
