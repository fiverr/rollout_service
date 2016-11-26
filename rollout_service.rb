$redis   = Redis.new
$rollout = Rollout.new($redis)

module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api


    group(:feature) { mount FeatureAPI}
    group(:group) { mount GroupAPI}

      # get :public_timeline do
    #   mount Twitter::APIv1
    #   mount Twitter::APIv
    #   {message:'this is a test'}.to_json
    # end

  end
end
