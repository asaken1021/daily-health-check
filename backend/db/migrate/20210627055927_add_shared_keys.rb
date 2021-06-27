class AddSharedKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :shared_keys do |t|
      t.string :key
    end
  end
end
