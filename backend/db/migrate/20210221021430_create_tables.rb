class CreateTables < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.string :class_name
      t.integer :class_number
      t.string :name
    end
    create_table :results do |t|
      t.integer :student_id
      t.float :temperature
      t.string :condition
      t.string :symptom
      t.timestamps null: false
    end
  end
end
