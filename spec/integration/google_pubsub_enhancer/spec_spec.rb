require 'spec_helper'

describe GooglePubsubEnhancer::Spec do

  include GooglePubsubEnhancer::Spec

  let(:messages) {[JSON.dump({alma:1}), JSON.dump({korte: 2}) ]}

  let(:expected_messages) { [ {"alma" => 1}, {"korte" => 2} ] }

  it "should behave like a pub/sub" do

    app = GooglePubsubEnhancer.new do

      use TestMiddleware, -> env do
         env[:messages_key] = env[:received_messages].map do |msg|
          JSON.parse msg.data
        end
      end

      use GooglePubsubEnhancer::Middleware::Publisher,
        short_topic_name: 'cica',
        messages: :messages_key
    end

    publish_called_with expected_messages

    app.run 'subscription_short_name'
  end
end
