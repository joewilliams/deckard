class Deckard
  class Ec2
    aws_key = Deckard::Config.aws_key
    aws_secret = Deckard::Config.aws_secret
    Ec2 = RightAws::Ec2.new(aws_key, aws_secret)

    def self.get_association(elastic_ip)
      Ec2.describe_addresses(elastic_ip)[0][:instance_id]
    end

    def self.associate_address(instance_id, elastic_ip)
      Ec2.associate_address(instance_id, elastic_ip)
    end

    def self.disassociate_address(elastic_ip)
      Ec2.disassociate_address(elastic_ip)
    end
  end
end
