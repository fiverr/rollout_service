module RolloutService
  module Api
    class System < Grape::API
      get '/ping' do
        "Pong from rollout-service, current time is #{Time.now}"
      end
    end
  end
end