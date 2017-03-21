module RolloutService
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    User = Struct.new(:name, :mail)

    helpers do
      def authenticate!
        response = HTTParty.post('https://www.googleapis.com/oauth2/v3/tokeninfo',
                                 body: {id_token: params[:id_token]})

        raise 'Bad response from server' if response.code != 200
        response_body = JSON.parse(response.body)

        if $google_oauth_allowed_domain.present? && response_body['hd'] != $google_oauth_allowed_domain
          raise 'Unauthorized user, this domain is not allowed'
        end


        $current_user = User.new(response_body['name'], response_body['email'])
        raise 'Unauthorized user' if $current_user.name.blank? || $current_user.mail.blank?

      rescue => e
        error!('401 Unauthorized', 401)
      end
    end

    mount SystemAPI

    resource(:features) { mount FeatureAPI }

  end
end
