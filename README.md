# Google::Pubsub::Enhancer

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/google/pubsub/enhancer`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google-pubsub-enhancer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google-pubsub-enhancer

## Usage

```ruby

require 'google_pubsub_enhancer'

app = GooglePubsubEnhancer.new do

  use YourMiddleware
  use GooglePubsubEnhancer::Publisher,
    short_topic_name: short_topic_name,
    messages: messages
end

app.run(subscription_name)

```

## ENV

To configure how much message should be pulled, use the GOOGLE_PUBSUB_ENHANCER_MAX_PULL_SIZE env variable with an integer value

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/google-pubsub-enhancer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
