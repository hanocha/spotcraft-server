# frozen_string_literal: true

require 'aws-sdk-ec2'

module AwsClient
  module EC2
    def self.client
      region = ENV['AWS_EC2_REGION'] || 'ap-northeast-1'
      profile = ENV['AWS_PROFILE'] || 'default'

      @client ||= Aws::EC2::Client.new(region: region, profile: profile)
    end

    def self.resource
      @resource ||= Aws::EC2::Resource.new(client: client)
    end

    def self.find_instance(name:)
      instances = client.describe_instances.reservations.map(&:instances).flatten
      instances.find { |i| i.tags.find { |tag| tag&.key == 'Name' }&.value == name }
    end

    def self.create_spot_instance(name:, instance_type: 't4g.nano')
      tags = [{ key: 'Name', value: name }]
      tag_resource_types = %w[instance volume network-interface spot-instances-request]
      tag_specifications = tag_resource_types.map { |type| { resource_type: type, tags: tags } }

      resource.create_instances({
        image_id: 'ami-0427ff21031d224a8',
        instance_type: instance_type,
        max_count: 1,
        min_count: 1,
        block_device_mappings: [
          {
            device_name: '/dev/xvda',
            ebs: {
              delete_on_termination: true,
              iops: 3000,
              volume_size: 50,
              volume_type: 'gp3',
              throughput: 125
            }
          }
        ],
        security_groups: ['public-ssh'],
        key_name: 'spotcraft-key',
        instance_initiated_shutdown_behavior: 'stop',
        tag_specifications: tag_specifications,
        instance_market_options: {
          market_type: 'spot',
          spot_options: {
            spot_instance_type: 'persistent',
            instance_interruption_behavior: 'stop'
          }
        }
      })
    end

    def self.create_spot_instance_by_request_spot_instances
      _res = client.request_spot_instances({
        instance_count: 1,
        launch_specification: {
          image_id: 'ami-0701e21c502689c31',
          instance_type: 't3.nano',
          key_name: 'spot-key-test',
          placement: {
            availability_zone: 'ap-northeast-1a'
          },
          security_groups: [
            'public-ssh'
          ]
        },
        tag_specifications: [
          {
            resource_type: 'spot-instances-request',
            tags: [
              {
                key: 'Name',
                value: 'spot-minecraft'
              }
            ]
          }
        ]
      })
    end
  end
end
