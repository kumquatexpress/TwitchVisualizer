class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
      t.integer :user_id
      t.string :name
      t.string :display_name
      t.timestamps
    end
  end
end
