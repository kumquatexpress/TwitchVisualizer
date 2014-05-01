class AddIndexJoin < ActiveRecord::Migration
  def change
    add_index(:channels_users, :channel_id)
    add_index(:channels_users, :user_id)
  end
end
