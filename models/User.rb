class User < ActiveRecord::Base
    has_and_belongs_to_many :channels

    self.primary_key = 'user_id'

    def get_cosine_similarity(other_id, channels)
        channel_vector = channels.map{|x| x.channel_id}.sort
        this_vector = Array.new(channel_vector.length){|i| 0}
        other_vector = Array.new(channel_vector.length){|i| 0}

        this_channels = self.channels.map{|x| x.channel_id}.sort
        other_channels = User.find(other_id).channels.map{|x| x.channel_id}.sort

        j = 0
        k = 0
        channel_vector.each_with_index do |ch, i|
            if this_channels[j] != channel_vector[i]
                this_vector[i] = 0
            else
                this_vector[i] = 1
                j += 1
            end
            if other_channels[k] != channel_vector[i]
                other_vector[i] = 0
            else
                other_vector[i] = 1
                k += 1
            end
        end
        dotprod = (0..this_vector.length-1).inject(0){|x, y| this_vector[y] * other_vector[y] + x}
        this_magnitude = (this_vector.inject(0){|x,y| x+y*y}) ** 0.5
        other_magnitude = (other_vector.inject(0){|x,y| x+y*y}) ** 0.5

        dotprod*1.0/(this_magnitude*other_magnitude)
    end

end