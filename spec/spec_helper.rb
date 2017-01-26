$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "google_pubsub_enhancer"

class TestMiddleware

  def initialize(app, block)
    @app = app
    @block = block
  end

  def call(env)
    @block.call(env)
    @app.call(env)
  end
end
