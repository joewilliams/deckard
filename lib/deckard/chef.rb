class Deckard
  class Chef
    
    def self.get_node_info(url)
      
      info = false
      
      if Deckard::Config.chef_enabled
      
        chef_url = Deckard::Config.chef_url
      
        begin
          chef_nodes_json = RestClient.get(chef_url)
          chef_nodes = JSON.parse(chef_nodes_json)

          chef_nodes["rows"].each do |row|
            if row["key"] == URI.parse(url).host
              info = row["value"]
            end
          end

        rescue Exception => e
          Deckard::Log.error("Could not get chef tag for alert on #{url} due to #{e}")
        end
      end
        
      info
    end
    
  end
end
