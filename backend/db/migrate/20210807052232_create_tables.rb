class CreateTables < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.integer :class_number
      t.string :name
    end
    create_table :class_names do |t|
      t.string :name
    end
    create_table :results do |t|
      t.float :temperature
      t.string :condition
      t.string :symptom
      t.timestamps null: false
    end
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.timestamps null: false
    end
    create_table :shared_keys do |t|
      t.string :key
    end
    create_table :student_class_names do |t|
      t.integer :student_id
      t.integer :class_id
    end
    create_table :result_class_names do |t|
      t.integer :result_id
      t.integer :class_id
      t.timestamps null: false
    end
    create_table :student_results do |t|
      t.integer :student_id
      t.integer :result_id
      t.timestamps null: false
    end
  end
end
