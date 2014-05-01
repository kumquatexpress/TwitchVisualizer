class Loader

    require 'net/http'
    require 'json'

    def self.get_channel_uri(channel)
        uri = "https://api.twitch.tv/kraken/channels/#{channel}"
        URI(uri)
    end

    def self.get_channel_follows_uri(channel)
        uri = self.get_channel_uri(channel+"/follows")
        URI(uri)
    end

    def self.get_user_follows_uri(user)
        uri = "https://api.twitch.tv/kraken/users/#{user}/follows/channels"
        URI(uri)
    end

    def self.get_user_uri(user)
        URI("https://api.twitch.tv/kraken/users/#{user}")
    end

    def self.load_users_from_channel(channel)

        dict = {}
        dict = JSON.parse(Net::HTTP.get(self.get_channel_follows_uri(channel)))

        follows = dict["follows"]

        ch = JSON.parse(Net::HTTP.get(self.get_channel_uri(channel)))
        begin
            c = Channel.find_or_create_by(
                display_name: ch["display_name"],
                name: ch["name"],
                channel_id: ch["_id"],
                followers: ch["followers"],
                views: ch["views"]
                )
        rescue
            c = Channel.find(ch["_id"])
        end

        while follows != []
            next_uri = URI(dict["_links"]["next"])

            follows.each do |follow|
                user = follow["user"]

                begin
                    u = User.find_or_create_by(
                        display_name: user["display_name"],
                        name: user["name"],
                        user_id: user["_id"]
                        )
                    u.channels << c
                    u.save
                rescue
                    print "Duplicate User!"
                end
            end
            
            if next_uri
                dict = JSON.parse(Net::HTTP.get(next_uri))
                follows = dict["follows"]
            else
                return
            end
        end
    end

    def self.load_channels_from_user(user)
        dict = {}
        dict = JSON.parse(Net::HTTP.get(self.get_user_follows_uri(user)))

        us = JSON.parse(Net::HTTP.get(self.get_user_uri(user)))
        begin
            u = User.find_or_create_by(
                display_name: us["display_name"],
                name: us["name"],
                user_id: us["_id"]
                )
        rescue
            u = User.find(us["_id"])
        end

        follows = dict["follows"]
        while follows != []
            next_uri = URI(dict["_links"]["next"])

            follows.each do |follow|
                channel = follow["channel"]

                begin
                    c = Channel.find_or_create_by(
                        display_name: channel["display_name"],
                        name: channel["name"],
                        channel_id: channel["_id"],
                        followers: channel["followers"],
                        views: channel["views"]
                        )
                rescue
                    c = Channel.find(channel["_id"])
                    unless c.users.include? u
                        c.users << u
                        c.save
                    end

                    unless u.channels.include? c
                        u.channels << c                    
                        u.save
                    end

                    print "Duplicate User!"
                end
            end
            
            if next_uri
                dict = JSON.parse(Net::HTTP.get(next_uri))
                follows = dict["follows"]
            else
                return
            end
        end
    end

    def self.split_into_threads(n, users)
        distance = users.length/n

        usernames = users.map{|x| x.name}

        threads = (1..n).map do |i|
            Thread.new(i) do |i|
                usernames[distance*i..distance*(i+1)].each do |u|
                    self.load_channels_from_user(u)
                end
            end
        end

        threads.each { |t| t.join }
    end

    def self.split_into_threads_ch(n, channels)
        distance = channels.length/n

        channelnames = channels.map{|x| x.name}

        threads = (1..n).map do |i|
            Thread.new(i) do |i|
                channelnames[distance*i..distance*(i+1)].each do |c|
                    self.load_users_from_channel(c)
                end
            end
        end

        threads.each { |t| t.join }
    end
end