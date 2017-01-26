class GooglePubsubEnhancer::Publisher

  def initialize(app, opts={})
    @app = app
    @short_topic_name = opts[:short_topic_name] || raise
    @full_topic_name = GooglePubsubEnhancer.name_by('topics',@short_topic_name)
    @messages_key = opts[:messages] || raise
  end

  def call(env)
    google_cloud_pubsub.publish(@full_topic_name) do |publisher|
      [*env[@messages_key]].each do |m|
        p m
        publisher.publish(m)
      end
    end
    @app.call(env)
  end

  def google_cloud_pubsub
    Google::Cloud::Pubsub.new
  end
end