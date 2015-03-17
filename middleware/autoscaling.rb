module AmazonSnsToSlack
  module Middleware
    class Autoscaling
      def call(json)
        begin
          message = JSON.parse(json["Message"])

          return nil unless message["AutoScalingGroupName"]

          payload = {
            "username" => "Amazon EC2 Autoscaling"
          }

          case message["Event"]
          when "autoscaling:TEST_NOTIFICATION"
            payload["attachments"] = [{
              "fallback" => json["Message"],
              "pretext" => "Test notification",
              "fields" => [
                {
                  "title" => "AutoScalingGroupName",
                  "value" => message["AutoScalingGroupName"]
                },
                {
                  "title" => "RequestId",
                  "value" => message["RequestId"]
                },
                {
                  "title" => "AccountId",
                  "value" => message["AccountId"]
                },
                {
                  "title" => "AutoScalingGroupARN",
                  "value" => message["AutoScalingGroupARN"]
                },
                {
                  "title" => "Time",
                  "value" => message["Time"]
                }
              ]
            }]
          when "autoscaling:EC2_INSTANCE_LAUNCH"
            payload["attachments"] = [{
              "fallback" => json["Message"],
              "pretext" => "Launching a new instance",
              "fields" => [
                {
                  "title" => "AutoScalingGroupName",
                  "value" => message["AutoScalingGroupName"]
                },
                {
                  "title" => "Description",
                  "value" => message["Description"]
                }
              ],
              "color" => "#7CD197"
            }]
          when "autoscaling:EC2_INSTANCE_TERMINATE"
            payload["attachments"] = [{
              "fallback" => json["Message"],
              "pretext" => "Terminating instance",
              "fields" => [
                {
                  "title" => "AutoScalingGroupName",
                  "value" => message["AutoScalingGroupName"]
                },
                {
                  "title" => "Description",
                  "value" => message["Description"]
                }
              ],
              "color" => "#F35A00"
            }]
          else
            payload["attachments"] = [{
              "fallback" => json["Message"],
              "pretext" => "@channel Caution!",
              "fields" => [
                {
                  "title" => "AutoScalingGroupName",
                  "value" => message["AutoScalingGroupName"]
                },
                {
                  "title" => "Description",
                  "value" => message["Description"]
                }
              ],
              "color" => "#FF0000"
            }]
          end

          payload
        rescue
          nil
        end
      end
    end
  end
end
