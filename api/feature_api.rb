class FeatureAPI < Grape::API

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      Feature.find(feature)
    end

    RestfulModels::Response.represent(data: features)
  end


  route_param :feature_name do
    params do
      requires :feature_name, type: Feature
    end
    get '/' do
      feature = params[:feature_name]

      if feature.valid?
        RestfulModels::Response.represent(data: feature)
      else
        status 500
        RestfulModels::Response.represent(message: 'Error, feature is not valid')
      end
    end

    params do
      requires :user_id, type: Integer, desc: 'The user ID'
      requires :feature_name, type: Feature
    end
    get '/:user_id/active' do
      user_id = params[:user_id].to_i
      feature = params[:feature_name]

      is_active = feature.active?(user_id)

      RestfulModels::Response.represent(data: { active: is_active })
    end

    params do
      requires :feature_name, type: Feature
      requires :id_token, type: String, desc: 'Google authentication id'
    end
    delete '/' do
      authenticate!
      feature = params[:feature_name]
      feature.delete
      ''
    end

    params do
      requires :description, type: String, desc: 'The feature description'
      requires :id_token, type: String, desc: 'Google authentication id'
      requires :feature_name, type: String
    end
    post '/' do
      authenticate!
      feature_name = params[:feature_name]
      error! 'Feature is already exist!' if Feature.exist?(feature_name)

      options = {
          name: feature_name,
          percentage: params[:percentage].to_i,
          description:  params[:description],
          author: $current_user.name,
          author_mail:  $current_user.mail,
          created_at: Time.current
      }

      feature = Feature.new(options)

      begin
        feature.save!
        Feature.set_users_to_feature(feature, params[:users])
        Feature.set_groups_to_feature(feature, params[:groups])
        RestfulModels::Response.represent(
            message: 'Feature created successfully!',
            data: feature
        )
      rescue => e
        status 500
        RestfulModels::Response.represent(message: "An error has been occurred.\r\n #{e}")
      end
    end

    params do
      requires :feature_name, type: Feature
      requires :id_token, type: String, desc: 'Google authentication id'
    end
    patch '/' do
      authenticate!
      feature = params[:feature_name]

      options = {
          percentage: params[:percentage].to_i,
          description:  params[:description],
          created_at: Time.current
      }

      # This is a temporary, will be deleted after all the features will be updated
      if feature.author.blank?
        options[:author] = $current_user.name
        options[:author_mail] = $current_user.mail
      end

      feature.assign_attributes(options)

      begin
        feature.save!
        Feature.set_users_to_feature(feature, params[:users])
        Feature.set_groups_to_feature(feature, params[:groups])
        RestfulModels::Response.represent(
            message: 'Feature updated successfully!',
            data: feature
        )
      rescue => e
        status 500
        RestfulModels::Response.represent(message: "An error has been occurred.\r\n #{e}")
      end
    end
  end
end