require 'json'
require 'middleware'
require 'google/cloud/pubsub'
require 'logger'

class GooglePubsubEnhancer

  require 'google_pubsub_enhancer/constants'
  require 'google_pubsub_enhancer/middleware'
  require 'google_pubsub_enhancer/spec'

  class << self
    def name_by(type, name)
      raise unless %w(topics subscriptions).include?(type)
      "projects/#{pubsub_config['project_id']}/#{type}/#{name}"
    end

    def pubsub_config
      key = ::Google::Cloud::Pubsub::Credentials::JSON_ENV_VARS.find { |n| !ENV[n].nil? }
      @pubsub_config ||= JSON.parse(ENV[key])
    rescue => ex
      raise Exception, 'Environment not setted properly'
    end
  end

  def initialize(logger: Logger.new(STDOUT),&block)
    @logger = logger
    @stack = ::Middleware::Builder.new(&block).__send__(:to_app)
  end

  def run(subscription_short_name, opts={})
    configurated_options = configurate_options(opts)
    subscription = create_subscription(subscription_short_name)
    work(subscription, configurated_options)
  rescue => ex
    @logger.error "Retry: #{ex} "
    retry
  end

  private

  def work(subscription, opts)
    return if opts[:shutdown].call
    while received_messages = subscription.pull(:max => GooglePubsubEnhancer::Constants::MAX_PULL_SIZE)
      break if opts[:shutdown].call || received_messages == nil
      next if received_messages.empty?
      @logger.debug{"#{received_messages.length} messages received"}
      @stack.call({received_messages: received_messages})
      subscription.acknowledge(received_messages)
    end
  end

  def create_subscription(subscription_short_name)
    Google::Cloud::Pubsub.new.subscription(self.class.name_by('subscriptions', subscription_short_name))
  rescue => ex
    raise Exception, 'Environment not setted properly'
  end

  def configurate_options(opts)
    raise unless opts.is_a?(Hash)
    opts[:shutdown] ||= proc { }
    opts
  end
end
