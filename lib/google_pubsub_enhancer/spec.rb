module GooglePubsubEnhancer::Spec
  module ClassMethods
    def __setup_pubsub!
      let(:messages) { [] }
      let(:pubsub) {double "pubsub"}
      let(:publisher) { double "publisher"}
      let(:subscription) { double 'subscription'}
      before do
        allow(ENV).to receive(:[]).with("PUBSUB_KEYFILE_JSON").and_return(JSON.dump({project_id: 'cica'}))
        allow(Google::Cloud::Pubsub).to receive(:new).and_return(pubsub)
        allow(pubsub).to receive(:publish).and_yield(publisher)
        allow(pubsub).to receive(:subscription).and_return subscription
        allow(subscription).to receive(:pull).and_return(messages.map { |m| Google::Cloud::Pubsub::Message.new(m.to_s)},nil)
        allow(publisher).to receive(:publish)
        allow(subscription).to receive(:acknowledge)
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
    klass.__setup_pubsub!
  end

end
