class Deckard
  class Ec2
    
    def self.get_association(region, elastic_ip)
      ec2 = ec2init(region)
  		ec2.describe_addresses(elastic_ip).body["addressesSet"][0]["instanceId"]
    end

    def self.associate_address(region, instance_id, elastic_ip)
			ec2 = ec2init(region)
      ec2.associate_address(instance_id, elastic_ip).body["return"]
    end

    def self.disassociate_address(region, elastic_ip)
      ec2 = ec2init(region)
      ec2.disassociate_address(elastic_ip).body["return"]
    end

    def self.ec2init(region)
      aws_key = Deckard::Config.aws_key
      aws_secret = Deckard::Config.aws_secret
    	
      Fog::AWS::Compute.new(
      	:aws_access_key_id => aws_key,
      	:aws_secret_access_key => aws_secret,
      	:region => region)
		end

  end
end
