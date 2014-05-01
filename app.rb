require "sinatra"
require "sinatra/activerecord"
require File.expand_path("../models/User", __FILE__) 
require File.expand_path("../models/Channel", __FILE__) 
require File.expand_path("../models/Loader", __FILE__) 
 

set :public_folder, File.dirname(__FILE__) + '/views'

ActiveRecord::Base.establish_connection(  
    adapter: "mysql2",  
    host: "localhost",  
    database: "twitchviz",
    username: "root",
    password: "kumquat"
)

get '/' do
    erb :main
end

get '/search/:user' do
    channels = json_k_neighbor_channels(params[:user], 10)
    channels.to_json
end

get '/cosinesim/:user' do
    json_cosine_sim(params[:user], 1000).to_json
end

def json_k_neighbor_channels(user, k)
    channels = Array.new
    channels += User.find_by_name(user).channels.to_a.sample(k)
    i = 0

    while channels.length < k
        ch = channels[i]
        ch.users.shuffle.each do |u|
            channels += u.channels.to_a.keep_if{|x| !channels.include? x }.sample(k - channels.length)
            unless channels.length < k
                break
            end
        end
        i += 1
    end

    combinations = {}

    channels.combination(2).to_a.each do |duo|
        fst, snd = duo
        combinations[[fst.id, snd.id]] = (fst.users.to_a.sample(1000) & snd.users.to_a.sample(1000)).length
    end
    
    h = channels.map{|x| x.followers}
    n = channels.map{|x| x.display_name}

    {data: h, names: n, combinations: combinations}
end

def json_cosine_sim(user1, k)
    user = User.find_by_name(user1)
    
    channels = user.channels.to_a.sample(10)
    users = []
    sims = []
    universe = []

    channels.each do |ch|
        users += ch.users.sample(k/channels.length)
    end

    users.each do |u|
        universe += u.channels
    end

    users.each do |u|
        sims << user.get_cosine_similarity(u.id, universe)
    end

    users, sims = users.zip(sims).keep_if{|x,y| y < 1.0 && x.id != user.id }.sort_by{|x,y| y}.reverse.transpose

    {data: sims, names: users.map{|x| x.display_name}.to_a}
end