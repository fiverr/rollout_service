module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    helpers do
      def authenticate!
        GoogleAuthentication.validate_token!(params)
      rescue => e
        error!('401 Unauthorized', 401)
      end
    end

    mount SystemAPI
    resource(:features) { mount FeatureAPI }

    add_swagger_documentation mount_path: '/docs'
  end
end
