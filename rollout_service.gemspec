# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rollout_service/version'

Gem::Specification.new do |spec|
  spec.name          = "rollout_service"
  spec.version       = RolloutService::VERSION
  spec.authors       = ["Yossi Eynav"]
  spec.email         = ["yossi.eynav@gmail.com"]
  spec.summary       = "This gem exposes rollout gem API"
  spec.homepage      = "https://www.fiverr.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'grape'
  spec.add_dependency 'grape-entity', '~> 0.5.0'
  spec.add_dependency 'rollout'
  spec.add_dependency 'redis'
  spec.add_dependency 'require_all'
  spec.add_dependency 'activesupport', '~> 5.0'
  spec.add_dependency 'active_attr', '~> 0.9.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
