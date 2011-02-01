class Deckard
  class Config

    if ARGV[0]
      monitor_config = YAML.load(File.open(ARGV[1]))
    else
      puts "No config file specified"
      abort
    end

    extend Mixlib::Config
    configure do |c|
      c[:email_to] = monitor_config["defaults"]["email_to"]
      c[:email_from] = monitor_config["defaults"]["email_from"]
      c[:email_host] = monitor_config["defaults"]["email_host"]
      c[:db_user] = monitor_config["defaults"]["db_user"]
      c[:db_password] = monitor_config["defaults"]["db_password"]
      c[:db_host] = monitor_config["defaults"]["db_host"]
      c[:db_port] = monitor_config["defaults"]["db_port"]
      c[:on_call_db] = monitor_config["defaults"]["on_call_db"]
      c[:on_call_doc] = monitor_config["defaults"]["on_call_doc"]
      c[:log_file] = monitor_config["defaults"]["log_file"]

      c[:content_check_retry] = monitor_config["content_check"]["retry_count"]
      c[:content_check_retry_interval] = monitor_config["content_check"]["retry_interval"]
      c[:content_check_db] = monitor_config["content_check"]["db"]
      c[:content_check_delay] = monitor_config["content_check"]["delay"]
      c[:content_check_delay_upper_bound] = monitor_config["content_check"]["delay_upper_bound"]

      c[:fo_check_retry] = monitor_config["fo_check"]["retry_count"]
      c[:aws_key] = monitor_config["fo_check"]["aws_key"]
      c[:aws_secret] = monitor_config["fo_check"]["aws_secret"]
      c[:fo_check_db] = monitor_config["fo_check"]["db"]

      c[:doc_behind_threshold] = monitor_config["rep_check"]["doc_behind_threshold"]
      c[:doc_ahead_threshold] = monitor_config["rep_check"]["doc_ahead_threshold"]
      c[:rep_check_db] = monitor_config["rep_check"]["db"]
      
      c[:notifo_user] = monitor_config["notifo"]["user"]
      c[:notifo_apikey] = monitor_config["notifo"]["apikey"]
      
      c[:stats_db] = monitor_config["stats"]["db"]
      
    end
  end
end
