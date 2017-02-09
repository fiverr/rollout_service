module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    mount SystemAPI

    resource(:features) { mount FeatureAPI }

  end
end
