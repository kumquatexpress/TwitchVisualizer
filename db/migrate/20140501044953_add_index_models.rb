class AddIndexModels < ActiveRecord::Migration
  def change
    add_index(:channels, :channel_id)
    add_index(:users, :user_id)
  end
end
