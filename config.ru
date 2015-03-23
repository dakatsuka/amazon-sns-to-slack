require 'bundler/setup'

Bundler.require

require './app'
require './service/autoscaling'
require './service/cloudwatch'

AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Service::Autoscaling
AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Service::CloudWatch

run AmazonSnsToSlack::Application
