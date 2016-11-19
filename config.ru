require 'bundler'
Bundler.require

require_rel 'models'
require_rel 'lib'
require_rel 'api_entities'
require_rel 'api'
require_rel 'rollout_service'


# $env = 'development'
# $env = ENV['RACK_ENV'] if defined?(ENV) && ENV['RACK_ENV']
# Dir.chdir 'service' if ENV['RM_INFO']
# puts "env :: #{$env}"

run RolloutService::API
