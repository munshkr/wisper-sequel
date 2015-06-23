# Wisper::Sequel

[![Build Status](https://travis-ci.org/munshkr/wisper-sequel.svg)](https://travis-ci.org/munshkr/wisper-sequel)
[![Code Climate](https://codeclimate.com/github/munshkr/wisper-sequel/badges/gpa.svg)](https://codeclimate.com/github/munshkr/wisper-sequel)
[![Test Coverage](https://codeclimate.com/github/munshkr/wisper-sequel/badges/coverage.svg)](https://codeclimate.com/github/munshkr/wisper-sequel/coverage)

A Sequel plugin for broadcasting model hooks as
[Wisper](https://github.com/krisleech/wisper) events.

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

This gem defines a Sequel Plugin, so if you want to make your model class
publish hook events, use `plugin :wisper`.  This will maker your model a
`Wisper::Publisher` and automatically broadcast all model hook events.

```ruby
class User < Sequel::Model
  plugin :wisper
end
```

You can also make all models broadcast:

```ruby
Sequel::Model.plugin :wisper
```

Please refer to the [Wisper README](https://github.com/krisleech/wisper) for
full details about subscribing.

Some of the events which are automatically broadcast are

* `create_<model_name>_{successful,failed}`
* `update_<model_name>_{successful,failed}`
* `destroy_<model_name>_{successful,failed}`

There is also an event per each model hook available.  The complete list is:

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

Please refer to [Sequel Model
Hooks](http://sequel.jeremyevans.net/rdoc/files/doc/model_hooks_rdoc.html)
document for full details about model hooks.

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
https://github.com/munshkr/wisper-sequel. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
