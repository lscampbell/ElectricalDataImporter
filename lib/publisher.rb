require 'json'
# Class used to publish data
class Publisher
  def initialize(client)
    @client = client
  end

  def publish(data_list)
    data_list.each do |d|
      @client.post '/profile', d.to_json
    end
  end
end