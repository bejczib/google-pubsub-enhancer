require 'spec_helper'

describe GooglePubsubEnhancer do
  let(:instance) { described_class.new(&block) }
  let(:block) { proc {} }
  let(:subscription) { double 'subscription' }
  let(:received_messages) { [double('message')] }

  let(:subscription_short_name) { 'subscription_short_name' }

  before do
    allow(ENV).to receive(:[]).with('PUBSUB_KEYFILE_JSON').and_return(JSON.dump(project_id: 'cica'))
    allow(Google::Cloud::Pubsub).to receive_message_chain(:new, :subscription).and_return(subscription)
    allow(subscription).to receive(:pull).and_return(received_messages, nil)
    allow(subscription).to receive(:acknowledge).with(received_messages)
  end

  describe '#run' do
    let(:opts) { {} }

    subject do
      instance.run(subscription_short_name, opts)
    end

    it 'should create a google pubsub subscription' do
      expected_subscription_name = 'projects/cica/subscriptions/subscription_short_name'
      expect(Google::Cloud::Pubsub).to receive_message_chain(:new, :subscription)
        .with(expected_subscription_name)
        .and_return(subscription)
      subject
    end

    context "when the env variables are not setted" do

      before do
        described_class.instance_exec{ @pubsub_config = nil}
        allow(ENV).to receive(:[]).and_return(nil)
      end

      it "should raise exception" do
        expect{subject}.to raise_error(Exception, 'Environment not setted properly')
      end

    end

    context 'when middleware is used ' do
      let(:elements) { [] }
      let(:block) do
        this = self
        proc do
          use TestMiddleware, proc { |env| this.elements.push(*env[:received_messages]) }
        end
      end

      it 'should pull the messages from the subscription' do
        subject
        expect(elements).to match_array(received_messages)
      end
    end

    context 'when middleware is used and something went wrong' do
      let(:elements) { [] }
      let(:runtime) { {} }
      let(:block) do
        this = self
        proc do
          boom_block = proc do
            if this.runtime[:raised].nil?
              this.runtime[:raised] = true
              raise 'Szevasztok!'
            end
          end

          normal_block = proc do |env|
            this.elements.push(*env[:received_messages])
          end

          use TestMiddleware, boom_block
          use TestMiddleware, normal_block
        end
      end

      it 'should retry the working process' do
        allow(subscription).to receive(:pull).and_return(['LOL'], received_messages, nil)
        expect { subject }.to_not raise_error
        expect(elements).to match_array(received_messages)
      end
    end


    context 'max pull size constant has value' do
      let(:user_defined_amount) {rand(1..20)}
      before{ stub_const("GooglePubsubEnhancer::Constants::MAX_PULL_SIZE", user_defined_amount) }

      it 'should be used for setting max amount for pulling from subscription' do
        expect(subscription).to receive(:pull).with({:max => user_defined_amount}).and_return(nil)
        subject
      end
    end

    context 'when shutdown specified' do
      before do
        opts[:shutdown] = proc { true }
      end

      let(:elements) { [] }

      let(:block) do
        this = self
        proc do
          normal_block = proc do |env|
            this.elements.push(*env[:received_messages])
          end

          use TestMiddleware, normal_block
        end
      end

      it 'should be used for determining wheter it should stop or not the processing' do
        subject
        expect(elements).to eq []
      end
    end
  end
end
