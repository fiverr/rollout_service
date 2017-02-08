class FeatureAPI < Grape::API

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = Feature.find(feature)
      RestfulModels::Feature.represent(feature)
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
        RestfulModels::Response.represent(data: RestfulModels::Feature.represent(feature))
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

      active = feature.active?(user_id: user_id)

      RestfulModels::Response.represent(data: { active: active })
    end

    params do
      requires :feature_name, type: Feature
    end
    delete '/' do
      feature = params[:feature_name]
      feature.delete
      ''
    end

    params do
      requires :description, type: String, desc: 'The feature description'
      requires :author, type: String, desc: 'The author name'
      requires :author_mail, type: String, desc: 'The author mail'
      requires :feature_name, type: String
    end
    post '/' do
      feature_name = params[:feature_name]
      error! 'Feature is already exist!' if Feature.exist?(feature_name)

      options = {
          name: feature_name,
          percentage: params[:percentage].to_i,
          description:  params[:description],
          last_author: params[:author],
          last_author_mail: params[:author_mail],
          created_at: Time.current,
          created_by: params[:author]
      }

      feature = Feature.new(options)

      begin
        feature.save!
        Feature.set_users_to_feature(feature, params[:users])
        RestfulModels::Response.represent(
            message: 'Feature created successfully!',
            data: RestfulModels::Feature.represent(feature)
        )
      rescue => e
        status 500
        RestfulModels::Response.represent(message: "An error has been occurred.\r\n #{e}")
      end
    end

    params do
      requires :last_author, type: String, desc: 'The author name'
      requires :last_author_mail, type: String, desc: 'The author email'
      requires :feature_name, type: Feature
    end
    patch '/' do
      feature = params[:feature_name]

      options = {
          percentage: params[:percentage].to_i,
          description:  params[:description],
          last_author: params[:last_author],
          last_author_mail: params[:last_author_mail],

          # This is a temporary, will be deleted after all the features will be updated/
          created_by: params[:created_by],
          created_at: Time.current
      }

      feature.assign_attributes(options)

      begin
        feature.save!
        Feature.set_users_to_feature(feature, params[:users])
        RestfulModels::Response.represent(
            message: 'Feature updated successfully!',
            data: RestfulModels::Feature.represent(feature)
        )
      rescue => e
        status 500
        RestfulModels::Response.represent(message: "An error has been occurred.\r\n #{e}")
      end
    end
  end
end