module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    resource(:features) { mount FeatureAPI }
    resource(:groups) { mount GroupAPI }

  end
end
