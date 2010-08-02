class Deckard
  class Monitor

    def self.content_check(url, content, priority, retry_count, schedule)
      check = true
      begin
        retries = 1 unless retries
        result = RestClient.get(url)
      rescue
        Deckard::Log.info("ALERT :: Could not connect to #{url}, retrying ...")
        sleep(Deckard::Config.content_check_retry_interval)
        retry if (retries += 1) < retry_count
        if retries >= retry_count
          subject = "ALERT :: Check Content Failed on #{url}"
          body = "Could not connect to #{url}"
          log = subject + " -- " + body
          Deckard::Util.alert(priority, subject, body, log, schedule, url)
          check = false
        end
      else
        retries = 1
        if result.include?(content)
          Deckard::Log.info("PASS :: Found text \"#{content}\" on #{url}")
        else
          subject = "ALERT :: Check Content Failed on #{url}"
          body = "Could not find text \"#{content}\" at #{url}"
          log = subject + " -- " + body
          Deckard::Util.alert(priority, subject, body, log, schedule, url)
          check = false
        end
      end
      check
    end

    def self.rep_check(name, master_url, slave_url, offset, priority, schedule)
      begin
        doc_behind_threshold = Deckard::Config.doc_behind_threshold
        doc_ahead_threshold = Deckard::Config.doc_ahead_threshold

        master_result = RestClient.get(master_url)
        slave_result = RestClient.get(slave_url)

        master_doc_count = JSON.parse(master_result)["doc_count"]
        slave_doc_count = JSON.parse(slave_result)["doc_count"]
        doc_count_diff = master_doc_count - slave_doc_count + offset

        if doc_count_diff >= doc_behind_threshold || doc_count_diff < doc_ahead_threshold
          subject = "ALERT :: Replication for #{name}"
          body = "Master: #{master_url} => Slave: #{slave_url} : off by #{doc_count_diff}"
          log = subject + " -- " + body
          Deckard::Util.alert(priority, subject, body, log, schedule, master_url)
        else
          Deckard::Log.info("PASS :: Replication for #{name} is OK (#{doc_count_diff})")
        end
      rescue
        # do nothing
      end
    end

    def self.failover(elastic_ip, primary_instance_id, secondary_instance_id, priority, schedule, failover)
      if failover
        begin
          subject = "ALERT :: #{elastic_ip} attempting failover!"
          body = "#{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id} attempting failover!"
          log = subject + " " + body
          Deckard::Util.alert(priority, subject, body, log, schedule, "http://#{elastic_ip}")

          instance_id = Deckard::Ec2.get_association(elastic_ip)
          Deckard::Ec2.disassociate_address(elastic_ip)
          Deckard::Log.info("ALERT :: Disassociated #{elastic_ip}")

          if instance_id == primary_instance_id
            Deckard::Ec2.associate_address(secondary_instance_id, elastic_ip)

            Deckard::Log.info("ALERT :: associated #{elastic_ip} to #{secondary_instance_id}")
            subject = "ALERT :: Failover Complete for #{elastic_ip} #{secondary_instance_id}"
            body = "VERIFY THINGS ARE WORKING! #{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id}"
            Deckard::Util.alert(priority, subject, body, subject, schedule, "http://#{elastic_ip}")
          elsif instance_id == secondary_instance_id
            Deckard::Ec2.associate_address(primary_instance_id, elastic_ip)

            Deckard::Log.info("ALERT :: associated #{elastic_ip} to #{primary_instance_id}")
            subject = "ALERT :: Failover Complete for #{elastic_ip} #{primary_instance_id}"
            body = "VERIFY THINGS ARE WORKING! #{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id}"
            Deckard::Util.alert(priority, subject, body, subject, schedule, "http://#{elastic_ip}")
          else
            error = "ALERT :: Could not a failover #{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id}!!"
            log = "ALERT :: Could not a failover #{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id}!! Due to instance_id != primary and secondary"
            Deckard::Util.alert(priority, error, error, log, schedule, "http://#{elastic_ip}")
          end
        rescue Exception => e
          error = "ALERT :: Could not a failover #{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id}!!"
          log = "ALERT :: Could not a failover #{elastic_ip} => #{primary_instance_id} / #{secondary_instance_id}!!"
          Deckard::Log.error(e)
          Deckard::Util.alert(priority, error, error, log, schedule, "http://#{elastic_ip}")
        end
      else
        # dont failover
        Deckard::Log.info("ALERT :: not failing over due to failover=false")
      end
    end

  end
end
