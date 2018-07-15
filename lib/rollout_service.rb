require 'rollout_service/version'
require 'require_all'
require 'grape'
require 'grape-entity'
require 'rollout'
require 'redis'
require 'active_support'
require 'active_attr'

require_rel 'rollout_service/config'
require_rel 'rollout_service/restful_models'
require_rel 'rollout_service/models'
require_rel 'rollout_service/api'

module RolloutService
  class Service < Grape::API
    format :json

    helpers do
      def current_user
        @current_user ||= User.new(env)
      end
    end

    resource(:features) { mount API::Features }
  end
end
