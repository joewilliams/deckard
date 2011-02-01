class Deckard
  class Stats
    
    def self.alert(priority, error, url, type)
      db_name = Deckard::Config.stats_db
      db_user = Deckard::Config.db_user
      db_password = Deckard::Config.db_password
      db_host = Deckard::Config.db_host
      db_port = Deckard::Config.db_port
      
      db_url = "http://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}"
      
      alert_info = {"priority" => priority, "error" => error, "url" => url, "timestamp" => Time.now.utc.iso8601, "type" => type}
      
      begin
        RestClient.post("#{db_url}", alert_info.to_json, "Content-Type" => "application/json")
        Deckard::Log.info("Added stats for alert on #{url}")
      rescue Exception => e
        Deckard::Log.error("Could not add stats for alert on #{url} due to #{e}")
      end
    end
    
  end
end