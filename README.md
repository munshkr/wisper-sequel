# Wisper::Sequel

A Sequel plugin for broadcasting model hooks as Wisper events.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wisper-sequel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wisper-sequel

## Usage

Please refer to the [Wisper README](https://github.com/krisleech/wisper) for
full details about subscribing.

The complete list of events which are automatically broadcasted are:

* `before_validation`
* `after_validation`
* `before_save`
* `after_save`
* `before_create`
* `after_create`
* `before_update`
* `after_update`
* `before_destroy`
* `after_destroy`
* `after_commit`
* `after_rollback`
* `after_destroy_commit`
* `after_destroy_rollback`

Some of the events are aliased to more meaningful names, like:

* `create_<model_name>_{successful,failed}` (uses `after_create`)
* `update_<model_name>_{successful,failed}` (uses `after_update`)
* `destroy_<model_name>_{successful,failed}` (uses `after_destroy`)
* `<model_name>_committed` (alias of `after_commit`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake rspec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/wisper-sequel. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
