require 'spec_helper'
require 'json'
require './service/cloudwatch'

describe AmazonSnsToSlack::Service::CloudWatch do
  describe "#call" do
    context "json parse error" do
      before do
        @json = {"Message" => '{'}
      end

      subject { AmazonSnsToSlack::Service::CloudWatch.new.call(@json) }
      it { should be_nil }
    end

    context "'AlarmName' not found" do
      before do
        @json = {"Message" => '{}'}
      end

      subject { AmazonSnsToSlack::Service::CloudWatch.new.call(@json) }
      it { should be_nil }
    end

    context "valid json with NewStateValud is 'ALARM'" do
      before do
        @json = {"Message" => '{"AlarmName":"cpu-utilization","AlarmDescription":null,"AWSAccountId":"3333333333","NewStateValue":"ALARM","NewStateReason":"Threshold Crossed: 1 datapoint (10.21) was greater than or equal to the threshold (10.0).","StateChangeTime":"2015-03-16T10:22:59.506+0000","Region":"APAC - Tokyo","OldStateValue":"OK","Trigger":{"MetricName":"CPUUtilization","Namespace":"AWS/EC2","Statistic":"AVERAGE","Unit":null,"Dimensions":[{"name":"AutoScalingGroupName","value":"asg"}],"Period":60,"EvaluationPeriods":1,"ComparisonOperator":"GreaterThanOrEqualToThreshold","Threshold":10.0}}'}
        @payload = AmazonSnsToSlack::Service::CloudWatch.new.call(@json)
      end

      it "return payload" do
        expect(@payload["username"]).to eq("Amazon CloudWatch")
        expect(@payload["attachments"][0]["text"]).to eq("Threshold Crossed: 1 datapoint (10.21) was greater than or equal to the threshold (10.0).")
        expect(@payload["attachments"][0]["color"]).to eq("#FF0000")
      end
    end

    context "valid json with NewStateValue is 'OK'" do
      before do
        @json = {"Message" => '{"AlarmName":"cpu-utilization","AlarmDescription":null,"AWSAccountId":"3333333333","NewStateValue":"OK","NewStateReason":"Threshold Crossed: 1 datapoint (9.29) was not greater than or equal to the threshold (10.0).","StateChangeTime":"2015-03-16T10:25:06.401+0000","Region":"APAC - Tokyo","OldStateValue":"ALARM","Trigger":{"MetricName":"CPUUtilization","Namespace":"AWS/EC2","Statistic":"AVERAGE","Unit":null,"Dimensions":[{"name":"AutoScalingGroupName","value":"asg"}],"Period":60,"EvaluationPeriods":1,"ComparisonOperator":"GreaterThanOrEqualToThreshold","Threshold":10.0}}'}
        @payload = AmazonSnsToSlack::Service::CloudWatch.new.call(@json)
      end

      it "return payload" do
        expect(@payload["username"]).to eq("Amazon CloudWatch")
        expect(@payload["attachments"][0]["text"]).to eq("Threshold Crossed: 1 datapoint (9.29) was not greater than or equal to the threshold (10.0).")
        expect(@payload["attachments"][0]["color"]).to eq("#7CD197")
      end
    end
  end
end
