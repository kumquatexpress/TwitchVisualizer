class Channel < ActiveRecord::Base
    has_and_belongs_to_many :users

    self.primary_key = 'channel_id'

end