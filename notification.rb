require 'uri'
require 'net/http'
require 'json'

module AmazonSnsToSlack
  module Notification
    class << self
      def use(klass)
        @middlewares = [] unless @middlewares
        @middlewares << klass
      end

      def middlewares
        @middlewares = [] unless @middlewares
        @middlewares
      end

      def notify(json)
        @middlewares.each do |m|
          m.new.call(json)
        end
      end
    end

    class Base
      def call(json)
        payload = {
          "attachments" => [
            {
              "fallback" => "New message from Amazon SNS - #{json['Subject']} - #{json['Message']}",
              "pretext" => "New message from Amazon SNS",
              "title" => json["Subject"] || "Untitle",
              "text"  => json["Message"],
              "color" => "#7CD197"
            }
          ]
        }
        send payload
      end

      def send(payload)
        payload["channel"]  ||= ENV["SLACK_CHANNEL"]
        payload["username"] ||= ENV["SLACK_USERNAME"]
        payload["icon_url"] ||= ENV["SLACK_ICON_URL"]

        Net::HTTP.post_form(URI.parse(ENV["SLACK_INCOMING_WEBHOOK_URL"]), {"payload" => payload.to_json})
      end
    end
  end
end
