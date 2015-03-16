require 'bundler/setup'

Bundler.require

require './app'
require './notification/autoscaling'
require './notification/cloudwatch'

AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Notification::Autoscaling
AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Notification::CloudWatch

run AmazonSnsToSlack::Application
