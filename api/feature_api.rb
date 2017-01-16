class FeatureAPI < Grape::API

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = Feature.find(feature)
      feature.valid? ?  RestfulModels::Feature.represent(feature) : nil
    end

    features = features.compact
    RestfulModels::Response.represent(data: features)
  end

  get '/:feature_name' do
    feature_name = params[:feature_name]
    feature = Feature.find(feature_name)
    if feature.valid?
      RestfulModels::Response.represent(data: RestfulModels::Feature.represent(feature))
    else
      RestfulModels::Response.represent(message: 'Error, feature is not valid')
    end
  end

  params do
    requires :user_id, type: Integer, desc: 'The user ID'
  end
  get '/:feature_name/active/:user_id' do
    feature_name = params[:feature_name]
    user_id = params[:user_id].to_i
    feature = Feature.find(feature_name)
    active = feature.active?(user_id)
    RestfulModels::Response.represent(data: {active: active})
  end


  delete '/:feature_name' do
    feature_name = params[:feature_name]
    feature = Feature.find(feature_name)
    feature.delete
    RestfulModels::Response.represent(message: 'The feature has been removed.')
  end


  params do
    requires :description, type: String, desc: 'The feature description'
    requires :author, type: String, desc: 'The author name'
  end
  post '/:feature_name' do
    author = params[:author]
    options = {
        name: params[:feature_name],
        percentage: params.fetch(:percentage),
        dogfood:  params.fetch(:dogfood),
        description:  params[:description],
        members:  params[:members],
        author: author
    }

    options.merge!({
       created_at: Time.current,
       created_by: author
    })

    options.delete_if { |_, value| value.blank? }

    feature = Feature.new(options)

    begin
      feature.save!
      RestfulModels::Response.represent(message: 'Feature created successfully!')
    rescue Exception
      RestfulModels::Response.represent(message: 'An error has been accord')
    end

  end

  params do
    requires :description, type: String, desc: 'The feature description'
    requires :author, type: String, desc: 'The author name'
  end
  put '/:feature_name' do
    feature_name = params[:feature_name]
    feature = Feature.find(feature_name)

    author = params[:author]
    options = {
        name: params[:feature_name],
        percentage: params[:percentage],
        dogfood:  params[:dogfood],
        description:  params[:description],
        members:  params[:members],
        author: author
    }

    options.delete_if { |_, value| value.blank? }

    feature.assign_attributes(**options)

    begin
      feature.save!
      RestfulModels::Response.represent(message: 'Feature updated successfully!')
    rescue Exception
      RestfulModels::Response.represent(message: 'An error has been accord')
    end

  end

end