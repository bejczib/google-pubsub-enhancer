class GooglePubsubEnhancer::Middleware::Logger::Duration

  def initialize(app,opts={},&substack)
    @app = app
    @logger = opts[:logger]
    @log_severity = opts[:log_severity]
    @substack = ::Middleware::Builder.new &substack
  end

  def call(env)
    measure_started = Time.now
    @substack.call(env)
    measure_stopped = Time.now
    @logger.send(@log_severity, "duration: #{measure_stopped - measure_started} sec")
    @app.call(env)
  end


end
