module GooglePubsubEnhancer::Constants
    MAX_PULL_SIZE = proc do
        user_defined = ::ENV['GOOGLE_PUBSUB_ENHANCER_MAX_PULL_SIZE']
        pull_size = (user_defined || 100).to_i
        raise('GOOGLE_PUBSUB_ENHANCER_MAX_PULL_SIZE') if pull_size == 0
        pull_size
    end.call.freeze
end