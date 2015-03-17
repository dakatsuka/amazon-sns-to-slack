module AmazonSnsToSlack
  module Middleware
    class CloudWatch
      def call(json)
        begin
          message = JSON.parse(json["Message"])

          return nil unless message["AlarmName"]

          payload = {
            "username" => "Amazon CloudWatch",
            "attachments" => [
              {
                "fallback" => json["Message"],
                "text" => message["NewStateReason"],
                "fields" => [
                  {
                    "title" => "Alarm",
                    "value" => message["AlarmName"],
                    "short" => true
                  },
                  {
                    "title" => "Status",
                    "value" => message["NewStateValue"],
                    "short" => true
                  }
                ]
              }
            ]
          }

          case message["NewStateValue"]
          when "OK"
            payload["attachments"]["color"] = "#7CD197"
          when "ALARM"
            payload["attachments"]["color"] = "#FF0000"
          end

          payload
        rescue
          nil
        end
      end
    end
  end
end
