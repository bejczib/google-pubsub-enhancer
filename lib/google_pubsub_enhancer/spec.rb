module GooglePubsubEnhancer::Spec
  module ClassMethods
    def __setup_pubsub!
      let(:messages) { [] }
      let(:pubsub) {double "pubsub"}
      let(:publisher) { double "publisher"}
      let(:subscription) { double 'subscription'}
      let(:google_messages) {messages.map { |m| Google::Cloud::Pubsub::Message.new(m.to_s)}}
      before do
        ENV['PUBSUB_KEYFILE_JSON'] = JSON.dump(project_id: 'cica')
        allow(Google::Cloud::Pubsub).to receive(:new).and_return(pubsub)
        allow(pubsub).to receive(:publish).and_yield(publisher)
        allow(pubsub).to receive(:subscription).and_return subscription
        allow(subscription).to receive(:pull).and_return(google_messages, nil)
        allow(publisher).to receive(:publish)
        allow(subscription).to receive(:acknowledge)
      end

      after do
        ENV.delete 'PUBSUB_KEYFILE_JSON'
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
    klass.__setup_pubsub!
  end

end
