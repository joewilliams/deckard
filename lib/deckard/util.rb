class Deckard
  class Util
    def self.get_nodes(db_name)
      doc_list = []
      node_list = []

      db_user = Deckard::Config.db_user
      db_password = Deckard::Config.db_password
      db_host = Deckard::Config.db_host
      db_port = Deckard::Config.db_port

      if db_user && db_password
        db_url = "http://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}"
      else
        db_url = "http://#{db_host}:#{db_port}/#{db_name}"
      end

      all_docs = RestClient.get("#{db_url}/_all_docs")

      all_docs_hash = JSON.parse(all_docs)

      all_docs_hash["rows"].each do |doc|
        doc_list << doc["id"]
      end

      doc_list.each do |doc|
        escaped_doc = CGI.escape(doc)
        node_json = RestClient.get("#{db_url}/#{escaped_doc}")
        node = JSON.parse(node_json)
        node_list << node
      end
      node_list
    end

    def self.alert(priority, subject, body, log, schedule)
      email_to = Deckard::Config.email_to
      sms_email = on_call

      # if scheduled maintenance set to logging only
      if schedule(schedule) == true
        priority = 0
      end

      if priority == 0
        Deckard::Log.info(log)
      elsif priority == 1
        Deckard::Log.info("sending email alert to #{email_to}")
        send_email(email_to, subject, body)
        Deckard::Log.info(log)
      elsif priority == 2
        Deckard::Log.info("sending email alert to #{email_to} and sms to #{sms_email}")
        send_email(email_to, subject, body)
        Deckard::Log.info(log)
        send_email("#{sms_email}", subject, body)
      end
    end

    def self.on_call
      db_user = Deckard::Config.db_user
      db_password = Deckard::Config.db_password
      db_host = Deckard::Config.db_host
      db_port = Deckard::Config.db_port
      db_name = Deckard::Config.on_call_db
      doc_name = Deckard::Config.on_call_doc

      doc_url = "http://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}/#{doc_name}"

      on_call = RestClient.get doc_url
      on_call_json = JSON.parse(on_call)
      on_call_json["sms_email"]
    end

    def self.send_email(email_addr, subject, body)
      to = email_addr
      from = Deckard::Config.email_from
      host = Deckard::Config.email_host
      mail = TMail::Mail.new
      mail.to = to
      mail.from = from
      mail.subject = subject
      mail.date = Time.now
      mail.mime_version = '1.0'
      mail.body = body

      Net::SMTP.start( host ) do |smtp|
        smtp.send_message(
          mail.to_s,
          from,
          to
        )
      end
    end

    def self.schedule(schedule)
      if schedule.nil?
        false
      else
        schedule.include? Time.now.hour
      end
    end

    def self.flip_failover(node)
      db_user = Deckard::Config.db_user
      db_password = Deckard::Config.db_password
      db_host = Deckard::Config.db_host
      db_port = Deckard::Config.db_port
      db_name = Deckard::Config.fo_check_db

      if db_user == "" || db_password == ""
        db_url = "http://#{db_host}:#{db_port}/#{db_name}"
      else
        db_url = "http://#{db_user}:#{db_password}@#{db_host}:#{db_port}/#{db_name}"
      end

      doc_json = RestClient.get("#{db_url}/#{node["_id"]}")
      doc = JSON.parse(doc_json)
      doc.store("failover", false)

      RestClient.put("#{db_url}/#{node["_id"]}?rev=#{node["_rev"]}", doc.to_json)
    end

  end
end
