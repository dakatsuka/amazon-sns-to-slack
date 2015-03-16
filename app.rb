require 'json'
require 'uri'
require 'net/http'
require './notification'

module AmazonSnsToSlack
  class FieldNotFoundException < StandardError; end
  class FailedSubscribeException < StandardError; end

  class Application < ::Sinatra::Base
    configure :production, :development do
      enable :logging
    end

    get '/' do
      'Ok'
    end

    post '/' do
      begin
        body = request.body.read
        json = JSON.parse(body)

        case json["Type"]
        when "SubscriptionConfirmation"
          subscribe! json
          logger.info "Subscribed to Amazon SNS. Topic #{json['TopicArn']}"
          status 200
        when "Notification"
          notify! json
          status 200
        else
          raise FieldNotFoundException.new("Field 'Type' not found exception")
        end
      rescue JSON::ParseError => e
        logger.info e.message
        status 422
      rescue FailedSubscribeException => e
        logger.error e.message
        status 500
      rescue => e
        logger.error e.message
        status 500
      end
    end

    helpers do
      def subscribe!(json)
        uri = URI.parse(json["SubscribeURL"])

        Net::HTTP.start(uri.host) do |req|
          res = req.get(uri.request_uri)
          raise FailedSubscribeException unless res.code == '200'
        end
      end

      def notify!(json)
        AmazonSnsToSlack::Notification.notify json
      end
    end
  end
end
