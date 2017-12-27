module RolloutService
  class Entry < Grape::API
    version 'v1'
    format :json
    prefix :api

    helpers do
      def authenticate!
        Api::GoogleAuthentication.validate_token!(params)
      rescue => e
        error!('401 Unauthorized', 401)
      end
    end

    mount Api::System
    resource(:features) { mount Api::Features }

    add_swagger_documentation mount_path: '/docs'
  end
end
