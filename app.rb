require 'json'
require 'uri'
require 'net/http'

module AmazonSnsToSlack
  class FieldNotFoundException < StandardError; end
  class FailedSubscribeException < StandardError; end

  class Notification
    @@middlewares = []

    class << self
      def use(klass)
        @@middlewares << klass
      end

      def middlewares
        @@middlewares
      end

      def send(json, logger)
        @@middlewares.each do |middleware|
          instance = middleware.new
          payload = instance.call(json)

          if payload && payload.length > 0
            send_to_slack(payload)
            logger.info("Sent to Slack channel #{payload['channel']}")
          end
        end
      end

      private
      def send_to_slack(payload)
        payload["channel"]  ||= ENV["SLACK_CHANNEL"]
        payload["username"] ||= ENV["SLACK_USERNAME"]
        payload["icon_url"] ||= ENV["SLACK_ICON_URL"]
        Net::HTTP.post_form(URI.parse(ENV["SLACK_INCOMING_WEBHOOK_URL"]), {"payload" => payload.to_json})
      end
    end
  end

  class Subscription
    class << self
      def subscribe(json)
        uri = URI.parse(json["SubscribeURL"])

        Net::HTTP.start(uri.host) do |req|
          res = req.get(uri.request_uri)
          raise FailedSubscribeException unless res.code == '200'
        end
      end
    end
  end

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
          Subscription.subscribe(json, logger)
          status 200
        when "Notification"
          Notification.send(json, logger)
          status 200
        else
          raise FieldNotFoundException.new("Field 'Type' not found exception")
        end
      rescue JSON::ParserError => e
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
  end
end
