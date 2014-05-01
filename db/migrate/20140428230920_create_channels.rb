class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels, id: false do |t|
      t.integer :channel_id
      t.string :name
      t.string :display_name
      t.integer :followers
      t.integer :views
      t.timestamps
    end

    execute "ALTER TABLE channels ADD PRIMARY KEY (channel_id);"
  end 
end
