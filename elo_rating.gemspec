# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elo_rating/version'

Gem::Specification.new do |spec|
  spec.name          = "elo_rating"
  spec.version       = EloRating::VERSION
  spec.authors       = ["Max Holder"]
  spec.email         = ["mxhold@gmail.com"]
  spec.summary       = "Tiny library for calculating Elo ratings"
  spec.description   = "Tiny library for calculating Elo ratings. Handles multiplayer matches and allows for custom k-factor functions."
  spec.homepage      = "http://github.com/mxhold/elo_rating"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
