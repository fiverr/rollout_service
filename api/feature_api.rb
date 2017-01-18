class FeatureAPI < Grape::API

  helpers do
    def feature_exist!
      feature_name = params[:name]
      error!('401 Unauthorized', 401) if feature_name.nil? || !Feature.exist?(feature_name)
    end
  end

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = Feature.find(feature)
      (feature.present? && feature.valid?) ? RestfulModels::Feature.represent(feature) : nil
    end

    features = features.compact
    RestfulModels::Response.represent(data: features)
  end

  route_param :name do
    get '/' do
      feature_exist!

      feature_name = params[:name]
      feature = Feature.find(feature_name)
      error!(status: 404, error: 'Feature not found') if feature.nil?

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

      feature_name = params[:name]
      user_id = params[:user_id].to_i
      remote_ip = params[:remote_ip]

      feature = Feature.find(feature_name)
      error!(status: 404, error: 'Feature not found') if feature.nil?

      active = feature.active?(user_id: user_id, remote_ip: remote_ip)

      RestfulModels::Response.represent(data: { active: active })
    end

    delete '/' do
      feature_exist!

      feature_name = params[:name]
      feature = Feature.find(feature_name)
      error!(status: 404, error: 'Feature not found') if feature.nil?

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
          dogfood:  params[:dogfood] == 'true',
          description:  params[:description],
          members:  params[:members],
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

      name = params[:name]
      feature = Feature.find(name)
      error!(status: 404, error: 'Feature not found') if feature.nil?

      options = {
          percentage: params[:percentage],
          dogfood:  params[:dogfood] == 'true',
          description:  params[:description],
          members:  params[:members],
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