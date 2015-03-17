require 'bundler/setup'

Bundler.require

require './app'
require './middleware/autoscaling'
require './middleware/cloudwatch'

AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Middleware::Autoscaling
AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Middleware::CloudWatch

run AmazonSnsToSlack::Application
