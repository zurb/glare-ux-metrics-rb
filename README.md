# Glare::UxMetrics

Welcome to Glare's UX Metric Framework! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/glare/ux-metrics/ux-metrics.rb`. To experiment with that code, run `bin/console` for an interactive prompt.

## Usage

```rb
sentiment_data = Glare::UxMetrics::Sentiment::Data.new(choices: {...})
sentiment_data.valid? # returns true
sentiment_data.parse # returns { label: "positive" , score: 1.2, threshold: "positive" }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zurb/glare-ux-metrics-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/zurb/glare-ux-metrics-rb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Glare::UxMetrics project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zurb/glare-ux-metrics-rb/blob/main/CODE_OF_CONDUCT.md).
