# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rollout_service/version'

Gem::Specification.new do |spec|
  spec.name          = "rollout_service"
  spec.version       = RolloutService::VERSION
  spec.authors       = ["Fiverr"]
  spec.email         = ["dev@fiverr.com"]
  spec.summary       = "This gem exposes rollout gem API"
  spec.homepage      = "https://www.fiverr.com"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'grape', '~> 1'
  spec.add_dependency 'grape-entity', '~> 0.5'
  spec.add_dependency 'rollout', '~> 2.4'
  spec.add_dependency 'redis',  '~> 4'
  spec.add_dependency 'require_all', '~> 2'
  spec.add_dependency 'activesupport', '~> 5'
  spec.add_dependency 'active_attr', '~> 0.9'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
