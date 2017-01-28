require 'json'
require 'middleware'
require 'google/cloud/pubsub'

class GooglePubsubEnhancer

  require_relative 'google_pubsub_enhancer/middleware'

  class << self
    def name_by(type, name)
      raise unless %w(topics subscriptions).include?(type)
      "projects/#{pubsub_config['project_id']}/#{type}/#{name}"
    end

    def pubsub_config
      key = ::Google::Cloud::Pubsub::Credentials::JSON_ENV_VARS.find { |n| !ENV[n].nil? }
      @pubsub_config ||= JSON.parse(ENV[key])
    end
  end

  def initialize(&block)
    @stack = ::Middleware::Builder.new(&block)
  end

  def run(subscription_short_name, opts={})
    configurated_options = configurate_options(opts)
    subscription = create_subscription(subscription_short_name)
    work(subscription, configurated_options)
  rescue
    retry
  end

  private

  def work(subscription, opts)
    while received_messages = subscription.pull
      break if opts[:shutdown].call || received_messages == nil
      next if received_messages.empty?
      @stack.call({received_messages: received_messages})
      subscription.acknowledge(received_messages)
    end
  end

  def create_subscription(subscription_short_name)
    Google::Cloud::Pubsub.new.subscription(self.class.name_by('subscriptions', subscription_short_name))
  end

  def configurate_options(opts)
    raise unless opts.is_a?(Hash)
    opts[:shutdown] ||= proc { }
    opts
  end
end
