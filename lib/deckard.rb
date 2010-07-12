require 'rubygems'

gem 'rest-client', '1.3.0'
require 'rest_client'
require 'tmail'
require 'json'
require 'cgi'
require 'net/smtp'
require 'right_aws'
require 'mixlib/log'
require 'mixlib/config'
require 'yaml'
require 'notifo'

__DIR__ = File.dirname(__FILE__)

$LOAD_PATH.unshift __DIR__ unless
  $LOAD_PATH.include?(__DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__DIR__))
  
require 'deckard/config'
require 'deckard/log'
require 'deckard/ec2'
require 'deckard/monitoring'
require 'deckard/util'


class Deckard
  
  def self.content_check
    retry_count = Deckard::Config.content_check_retry
    db_name = Deckard::Config.content_check_db
    list = Array.new

    nodes = Deckard::Util.get_nodes(db_name)

    nodes.each do |node|
      run = Thread.new {
        Deckard::Monitor.content_check(node["url"], node["content"], node["priority"], retry_count, node["schedule"])
        }
      list << run
    end

    list.each { |x|
     	  x.join
    }
  end

  def self.rep_check
    db_name = Deckard::Config.rep_check_db
    list = Array.new

    nodes = Deckard::Util.get_nodes(db_name)

    nodes.each do |node|
      run = Thread.new {
        Deckard::Monitor.rep_check(node["name"], node["master_url"], node["slave_url"], node["offset"], node["priority"], node["schedule"])
        }
      list << run
    end

    list.each { |x|
     	  x.join
    }
  end

  def self.fo_check
    retry_count = Deckard::Config.fo_check_retry
    db_name = Deckard::Config.fo_check_db
    list = Array.new

    nodes = Deckard::Util.get_nodes(db_name)

    nodes.each do |node|
      run = Thread.new {
        check = Deckard::Monitor.content_check(node["url"], node["content"], node["priority"], retry_count, node["schedule"])
        unless check
          Deckard::Monitor.failover(node["elastic_ip"], node["primary_instance_id"], node["secondary_instance_id"], node["priority"], node["schedule"], node["failover"])
          Deckard::Util.flip_failover(node)
        end
        }
      list << run
    end

    list.each { |x|
      x.join
    }
  end

  def self.main
    list = Array.new

    list << Thread.new { content_check }
    list << Thread.new { rep_check }
    list << Thread.new { fo_check }

    list.each { |x|
      x.join
    }
  end

end