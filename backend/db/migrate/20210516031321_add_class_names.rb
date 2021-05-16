class AddClassNames < ActiveRecord::Migration[6.1]
  def change
    create_table :class_names do |t|
      t.string :class_name
    end
  end
end
