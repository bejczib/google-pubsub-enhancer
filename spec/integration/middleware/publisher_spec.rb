require 'spec_helper'

describe GooglePubsubEnhancer::Middleware::Publisher do

  let(:instance) { described_class.new(app, short_topic_name: short_topic_name, messages: messages, logger: logger)}
  let(:app) { double 'chained_middleware'}
  let(:short_topic_name) { 'valami'}
  let(:messages) {:alma}
  let(:logger) { double 'logger' }
  let(:env) {{alma: [{korte:1}]}}
  let(:pubsub_client_mock) { double( 'pubsub')}
  let(:publisher_mock) { double 'publisher_mock' }

  subject { instance.call env }

  before do
    ENV['PUBSUB_KEYFILE_JSON'] = JSON.dump(project_id: 'cica')
    allow(Google::Cloud::Pubsub).to receive(:new).and_return(pubsub_client_mock)
    allow(pubsub_client_mock).to receive(:publish).with("projects/cica/topics/valami").and_yield(publisher_mock)
    allow(app).to receive(:call)
    allow(logger).to receive(:debug)
    allow(Digest::MD5).to receive(:hexdigest).and_return('asd323asd')
  end

  after do
    ENV.delete 'PUBSUB_KEYFILE_JSON'
  end


  it 'should push the received elements with its md5 hash to google pubsub topic' do
    expect(publisher_mock).to receive(:publish).with({korte: 1}, {recordId: 'asd323asd'})

    subject
  end

  context 'when something went wrong during the publishing' do

    before do
      call_count = 0
      allow(publisher_mock).to receive(:publish).with({korte: 1},{recordId: 'asd323asd'}).twice do
        raise "zsafol" if (call_count += 1) == 1
      end
       allow(logger).to receive(:error)
       allow(logger).to receive(:debug)
    end


    it "should retry the process and log event" do
      expect(publisher_mock).to receive(:publish).with({korte: 1},{recordId: 'asd323asd'}).ordered
      expect(logger).to receive(:error).with("Retry publisher: zsafol").ordered
      expect(publisher_mock).to receive(:publish).with({korte: 1}, {recordId: 'asd323asd'}).ordered

      subject
    end

  end
end
