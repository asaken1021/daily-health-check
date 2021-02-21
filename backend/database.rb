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