# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisper/sequel/version'

Gem::Specification.new do |spec|
  spec.name          = "wisper-sequel"
  spec.version       = Wisper::Sequel::VERSION
  spec.authors       = ["Damián Silvani"]
  spec.email         = ["munshkr@gmail.com"]

  spec.summary       = %q{A Sequel plugin for broadcasting model hooks as Wisper events.}
  spec.description   = %q{Transparently publish model lifecycle events to subscribers.}
  spec.homepage      = "https://github.com/munshkr/wisper-sequel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "wisper-rspec"
  spec.add_development_dependency "sqlite3"

  spec.add_runtime_dependency "wisper", "~> 1.6"
  spec.add_runtime_dependency "sequel"
end
