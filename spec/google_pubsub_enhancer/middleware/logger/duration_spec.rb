require 'spec_helper'

describe GooglePubsubEnhancer::Middleware::Logger::Duration do

  let(:instance) { described_class.new(app, logger: logger, log_severity: log_severity,  &substack)}
  let(:app) { double("next middleware")}
  let(:logger) { double('logger')}
  let(:log_severity) { :info }
  let(:substack) do
    proc do
      use TestMiddleware, proc {sleep 2}
    end
  end
  let(:env) {{}}
  before do
    allow(app).to receive(:call).with(env)
    allow(Time).to receive(:now).and_return(2,4)
  end

  it "should measure how much time does the stack call costs" do
    expect(logger).to receive(:info).with("duration: 2 sec")
    instance.call(env)

  end


end
