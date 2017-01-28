require 'spec_helper'

describe GooglePubsubEnhancer::Middleware::Publisher do

  let(:instance) { described_class.new(app, short_topic_name: short_topic_name, messages: messages)}
  let(:app) { double 'chained_middleware'}
  let(:short_topic_name) { 'valami'}
  let(:messages) {:alma}
  let(:env) {{alma: [{korte:1}]}}
  let(:pubsub_client_mock) { double( 'pubsub')}
  let(:publisher_mock) { double 'publisher_mock' }

  before do
    allow(ENV).to receive(:[]).with("PUBSUB_KEYFILE_JSON").and_return(JSON.dump({project_id: 'cica'}))
    allow(Google::Cloud::Pubsub).to receive(:new).and_return(pubsub_client_mock)
    allow(pubsub_client_mock).to receive(:publish).with("projects/cica/topics/valami").and_yield(publisher_mock)
    allow(app).to receive(:call)
  end

  it 'should push the received elements to google pubsub topic' do
    expect(publisher_mock).to receive(:publish).with({korte: 1})

    instance.call(env)
  end
end
