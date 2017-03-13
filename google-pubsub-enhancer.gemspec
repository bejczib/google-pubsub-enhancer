# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_pubsub_enhancer/version'

Gem::Specification.new do |spec|
  spec.name          = "google-pubsub-enhancer"
  spec.version       = GooglePubsubEnhancer::VERSION
  spec.authors       = ["bejczib","karoly_bujtor"]
  spec.email         = ["bejczi.balint@gmail.com","bujtor.karoly@gmail.com"]

  spec.summary       = %q{Enhancement for a pipeline built with Google PubSub Services }
  spec.homepage      = "http://github.com/bejczib/google-pubsub-enhancer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "middleware", "~>0"
  spec.add_dependency "google-cloud-pubsub", "~>0"
end
