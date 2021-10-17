# frozen_string_literal: true

require 'sinatra'
require_relative './lib/aws_client'

set :bind, '0.0.0.0'

get '/instance' do
  instance = AwsClient::EC2.find_instance(name: 'spot-minecraft')
  instance.to_json
end
