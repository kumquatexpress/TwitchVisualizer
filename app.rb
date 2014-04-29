require "sinatra"
require "sinatra/activerecord"
 
set :database, "sqlite3:///project.db"
 
class User < ActiveRecord::Base
    has_and_belongs_to_many :channels

    self.primary_key = 'user_id'

end

class Channel < ActiveRecord::Base
    has_and_belongs_to_many :users

    self.primary_key = 'channel_id'
    
end