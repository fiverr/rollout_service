class GroupAPI < Grape::API

  DEFAULT_DELIMETER = ','

  helpers do
    def feature_exist!
      feature_name = params[:name]
      error!('401 Unauthorized', 401) if feature_name.nil? || !Feature.exist?(feature_name)
    end
  end

  route_param :name do

    post '/' do
      group_name = params[:name]
      delimiter = params.fetch(:delimiter, DEFAULT_DELIMETER)
      group = params.fetch(:group)

      response = $rollout.define_group(group_name) do |user_id|
        user_id.is_a?(Numeric) &&
            group.split(delimiter).include?(user_id)
      end
      RestfulModels::Response.represent(message: response)
    end

    delete '/' do
      feature_exist!
      feature_name = params[:name]
      user_id = params[:user_id]
      response = $rollout.deactivate_user(feature_name,user_id)
      RestfulModels::Response.represent(message: response)
    end

  end
end