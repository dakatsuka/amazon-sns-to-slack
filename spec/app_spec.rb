ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'rack/test'
require './app'

describe AmazonSnsToSlack::Application do
  include Rack::Test::Methods

  def app
    AmazonSnsToSlack::Application
  end

  describe "GET /" do
    before { get '/' }

    it "response should be ok" do
      expect(last_response).to be_ok
      expect(last_response.body).to eq('OK')
    end
  end

  describe "POST /" do
    context "SubscriptionConfirmation" do
      before do
        allow(AmazonSnsToSlack::Subscription).to receive :subscribe
        post '/', '{"Type": "SubscriptionConfirmation"}'
      end

      it "response should be ok" do
        expect(last_response).to be_ok
      end
    end

    context "Notification" do
      before do
        allow(AmazonSnsToSlack::Notification).to receive :send
        post '/', '{"Type": "Notification"}'
      end

      it "response should be ok" do
        expect(last_response).to be_ok
      end
    end
  end
end
