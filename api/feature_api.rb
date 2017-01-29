class FeatureAPI < Grape::API

  helpers do
    def feature_exist!
      feature_name = params[:name]
      error!('Resource not found.', 404) if feature_name.nil? || !Feature.exist?(feature_name)
    end

    def current_feature
      feature_name = params[:name]
      return nil if feature_name.nil?

      Feature.find(feature_name)
    end
  end

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = Feature.find(feature)
      RestfulModels::Feature.represent(feature)
    end

    RestfulModels::Response.represent(data: features)
  end

  route_param :name do

    params do
      requires :user_id, type: Integer, desc: 'The user ID'
    end
    route_param :user_id do
      post '/' do
        feature_exist!
        feature = current_feature

        user_id = params[:user_id]
        response = feature.add_user(user_id)

        RestfulModels::Response.represent(message: response)
      end

      delete '/' do
        feature_exist!
        user_id = params[:user_id]
        feature = current_feature

        response = feature.remove_user(user_id)

        status 200
        RestfulModels::Response.represent(message: response)
      end
    end

    get '/' do
      feature_exist!
      feature = current_feature

      if feature.valid?
        RestfulModels::Response.represent(data: RestfulModels::Feature.represent(feature))
      else
        status 500
        RestfulModels::Response.represent(message: 'Error, feature is not valid')
      end
    end

    params do
      requires :user_id, type: Integer, desc: 'The user ID'
    end
    get '/:user_id/active' do
      feature_exist!

      user_id = params[:user_id].to_i
      feature = current_feature

      active = feature.active?(user_id: user_id)

      RestfulModels::Response.represent(data: { active: active })
    end

    delete '/' do
      feature_exist!
      feature = current_feature

      feature.delete
      RestfulModels::Response.represent(message: 'The feature has been removed.')
    end

    params do
      requires :description, type: String, desc: 'The feature description'
      requires :author, type: String, desc: 'The author name'
    end
    post '/' do
      options = {
          name: params[:name],
          percentage: params[:percentage] || 0,
          description:  params[:description],
          author: params[:author],
          created_at: Time.current,
          created_by: params[:author]
      }

      feature = Feature.new(options)

      begin
        feature.save!
        RestfulModels::Response.represent(message: 'Feature created successfully!')
      rescue Exception
        status 500
        RestfulModels::Response.represent(message: 'An error has been accord')
      end
    end

    params do
      requires :author, type: String, desc: 'The author name'
    end
    patch '/' do
      feature_exist!
      feature = current_feature

      options = {
          percentage: params[:percentage],
          description:  params[:description],
          author: params[:author]
      }

      feature.assign_attributes(options)

      begin
        feature.save!
        RestfulModels::Response.represent(message: 'Feature updated successfully!')
      rescue Exception
        status 500
        RestfulModels::Response.represent(message: 'An error has been accord')
      end
    end
  end
end