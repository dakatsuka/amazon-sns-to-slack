# Amazon SNS to Slack [![Build Status](https://travis-ci.org/dakatsuka/amazon-sns-to-slack.svg?branch=master)](https://travis-ci.org/dakatsuka/amazon-sns-to-slack)

Relay to a Slack channel from Amazon SNS.

Support the following services:

* Amazon CloudWatch
* Amazon EC2 Autoscaling

## Requirements

* Amazon Web Service account
* Slack account with Incoming Webhook Token
* Heroku account

## Installation

Deploy to Heroku:

```
$ git clone git@github.com:dakatsuka/amazon-sns-to-slack.git
$ cd amazon-sns-to-slack
$ bundle install
$ bundle exec heroku create your-application-name
$ bundle exec heroku config:set SLACK_CHANNEL="#channel" \
                                SLACK_USERNAME="Amazon SNS" \
                                SLACK_INCOMING_WEBHOOK_URL="https://" \
                                SLACK_ICON_URL="https://i.imgur.com/zUUsRLa.png"
$ git push heroku master
```


Quick deployment:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy) 

## Customize

Please implement the call method that returns the payload.

```ruby
class CustomService
  def call(json)
    subject = json["Subject"] || "Default Subject"
    message = JSON.parse(json["Message"])

    payload = { "username" => "original user", "attachments" => [{...}] }
    payload
  end
end
```

Modify config.ru:

```ruby
require './custom_service'

# AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Service::Autoscaling
# AmazonSnsToSlack::Notification.use AmazonSnsToSlack::Service::CloudWatch
AmazonSnsToSlack::Notification.use CustomService
```
