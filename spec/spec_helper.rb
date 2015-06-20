$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wisper/sequel'
require 'wisper/rspec/matchers'

RSpec::configure do |config|
  config.include(Wisper::RSpec::BroadcastMatcher)
end
