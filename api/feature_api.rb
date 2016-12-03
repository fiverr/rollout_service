class FeatureAPI < Grape::API

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = $rollout.get(feature)
      feature.data['script'] = Script.unserialized(feature.data['script']).as_json if feature.data['script'].present?
      Feature.represent(feature)
    end
    Response.new(features)
  end

  get '/:feature_name' do
    feature_name = params[:feature_name]
    feature = $rollout.get(feature_name)
    feature = Feature.represent(feature)
    Response.new(feature)
  end

  post '/:feature_name' do
    feature_name = params[:feature_name]
    percentage = params[:percentage] || 0
    $rollout.activate_percentage(feature_name, percentage)
    $rollout.set_feature_data(feature_name,  params[:meta_data])
    Response.new({},'Feature created successfully!')
  end
end
