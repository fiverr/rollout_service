class FeatureAPI < Grape::API

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = $rollout.get(feature)
      Feature.represent(feature)
    end

    Response.represent(data: features)
  end

  get '/:feature_name' do
    feature_name = params[:feature_name]
    feature = $rollout.get(feature_name)
    feature = Feature.represent(feature)
    Response.new(data: feature)
  end

  post '/:feature_name/:group_name' do
    feature_name = params[:feature_name]
    group_name = params[:group_name]

    response = $rollout.activate_group(feature_name, group_name)
    Response.new(message: response)
  end

  post '/:feature_name' do
    feature_name = params[:feature_name]
    percentage = params[:percentage] || 0
    $rollout.activate_percentage(feature_name, percentage)
    $rollout.set_feature_data(feature_name,  params[:meta_data])
    Response.new(message: 'Feature created successfully!')
  end

  delete '/:feature_name/:group_name' do
    feature_name = params[:feature_name]
    group_name = params[:group_name]

    response = $rollout.deactivate_group(feature_name, group_name)
    Response.new(message: response)
  end
end
