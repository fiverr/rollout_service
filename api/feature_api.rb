class FeatureAPI < Grape::API

  get '/' do
    features = $rollout.features
    features.map! do|feature|
      feature = $rollout.get(feature)
      FeatureEntity.represent(feature)
    end
    Response.new(features)
  end

  get '/:feature' do
    feature = $rollout.get(:feature)
    feature = FeatureEntity.represent(feature)
    Response.new(feature)
  end

  post '/:feature' do
    feature_name = params[:feature]
    percentage = params[:percentage] || 0
    $rollout.activate_percentage(feature_name, percentage)
    $rollout.set_feature_data(feature_name,  params[:meta_data])
    {}
  end
end
