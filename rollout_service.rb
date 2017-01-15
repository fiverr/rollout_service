module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    group(:feature) { mount FeatureAPI }

  end
end
