require 'spec_helper'

describe GooglePubsubEnhancer::Spec do

  include GooglePubsubEnhancer::Spec

  let(:messages) {[{alma:1}, {korte: 2}]}

  it "should behave like a pub/sub" do

    app = GooglePubsubEnhancer.new do

      use TestMiddleware, -> env do
        env[:messages_key] = env[:received_messages].map(&:data)
      end

      use GooglePubsubEnhancer::Middleware::Publisher,
        short_topic_name: 'cica',
        messages: :messages_key
    end

    expect(publisher).to receive(:publish).exactly(2).times
    app.run 'subscription_short_name'
  end
end
