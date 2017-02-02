require 'bundler'
Bundler.require

require_rel 'syslib'
Globals.setup

require_rel 'restful_models'
require_rel 'models'
require_rel 'api'
require_rel 'rollout_service'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :patch, :options]
  end
end

run RolloutService::API