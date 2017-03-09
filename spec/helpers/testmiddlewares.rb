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

class NackMiddleware

  def initialize(app,opts={})
    @app = app
  end

  def call(env)
    env[:nacked_messages] = [1]
    @app.call(env)
  end

end
