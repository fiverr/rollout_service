module GoogleAuthentication
    extend self

    User = Struct.new(:name, :mail)
    TOKEN_INFO_END_POINT = 'https://www.googleapis.com/oauth2/v3/tokeninfo'

    def validate_token!(params)
    response = HTTParty.post(TOKEN_INFO_END_POINT,
                                 body: {id_token: params[:id_token]})
    raise 'Bad response from server' if response.code != 200

    response_body = JSON.parse(response.body)
    raise 'Unauthorized user' if response_body['name'].blank? || response_body['email'].blank?
    validate_mail!(response_body)

    $current_user = User.new(response_body['name'], response_body['email'])
    end

    private

    def validate_mail!(response_body)
        return true if $google_oauth_allowed_domain.blank?
        raise 'Unauthorized user, this domain is not allowed' if response_body['hd'] != $google_oauth_allowed_domain
    end
end