module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    rescue_from :all do |_|
      error!({status: 500})
    end

    resource(:features) { mount FeatureAPI }

  end
end
