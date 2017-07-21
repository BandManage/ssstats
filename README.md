# SSStats - Stupid Simple Statistics (for unstructured data)

Consumes simple data structures, produces elementary statistics

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ssstats'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ssstats

## Usage

```ruby
require 'ssstats'

stats = Ssstats.new

stats << {weather: {temperature: 32.0}, score: {'Real' => 2, 'Barcelona' => 2}}
stats << {weather: "freezing", score: {'Real' => 1, 'Barcelona' => 0}}

stats.schema  # {'weather' => [{'temperature' => 0.0}, ""], 'score' => {'Real' => 0, 'Barcelona' => 0}}

stats.avg  # {'.Hash.length' => 2.0, 'weather.Hash.length' => 1.0, 'weather.temperature.Float' => 32.0, 'score.Hash.length' => 2.0, 'score.Real.Integer' => 1.5, 'score.Barcelona.Integer' => 1.0, 'weather.String.length' => 8.0}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bandmanage/ssstats.

