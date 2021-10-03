require 'aws-sdk-ec2'

module AwsClient
  module EC2
    def self.client
      region = ENV['AWS_EC2_REGION'] || 'ap-northeast-1'
      profile = ENV['AWS_PROFILE'] || 'default'

      @client ||= Aws::EC2::Client.new(region: region, profile: profile)
    end

    def self.find_instance(name:)
      instances = client.describe_instances.reservations.map(&:instances).flatten
      instances.find { |i| i.tags.find { |tag| tag.key == "Name" }.value == name }
    end
  end
end
