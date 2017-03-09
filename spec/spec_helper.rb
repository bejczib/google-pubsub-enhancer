$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "google_pubsub_enhancer"

Dir[File.join(File.dirname(__FILE__), 'helpers', '*.rb')].each do |file|
  require file
end
