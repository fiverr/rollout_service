require 'bundler'
Bundler.require

require_rel 'syslib'
Globals.setup

# require_rel 'models'
require_rel 'restful_models'
require_rel 'api'
require_rel 'rollout_service'

run RolloutService::API
