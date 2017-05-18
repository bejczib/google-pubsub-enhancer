module GooglePubsubEnhancer::Spec
  module ClassMethods
    def __setup_pubsub!
      let(:messages) { [] }
      let(:pubsub) {double "pubsub"}
      let(:publisher) { double "publisher"}
      let(:subscription) { double 'subscription'}
      let(:google_messages) {messages.map { |m| Google::Cloud::Pubsub::Message.new(m)}}

      before do
        ENV['PUBSUB_KEYFILE_JSON'] = JSON.dump(project_id: 'cica')
        allow(Google::Cloud::Pubsub).to receive(:new).and_return(pubsub)
        allow(pubsub).to receive(:publish).and_yield(publisher)
        allow(pubsub).to receive(:subscription).and_return subscription
        allow(subscription).to receive(:pull).and_return(google_messages, nil)
        allow(publisher).to receive(:publish)
        allow(subscription).to receive(:acknowledge)
        allow(Digest::MD5).to receive(:hexdigest).and_return("a1s2d3f4g5")
      end

      after do
        ENV.delete 'PUBSUB_KEYFILE_JSON'
      end
    end
  end

  module PublisherTester
    def publish_called_with(msg)
      expect(publisher).to receive(:publish).with(msg, {recordId: "a1s2d3f4g5"}).ordered
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
    klass.__setup_pubsub!
    RSpec.configuration.include(PublisherTester)
  end



end
