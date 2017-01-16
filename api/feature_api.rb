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
    Response.represent(data: feature)
  end

  params do
    requires :user_id, type: Integer, desc: 'The user ID'
  end
  get '/:feature_name/active/:user_id' do
    feature_name = params[:feature_name]
    user_id = params[:user_id].to_i
    feature_active = false

    feature_active = true if $rollout.active?(feature_name, user_id)

    unless feature_active
      feature_data = $rollout.multi_get(feature_name).last.data
      members = feature_data.fetch('members', [])
      feature_active = true if members.include?(user_id)
    end

    Response.represent(data: {active: feature_active})
  end


  delete '/:feature_name' do
    feature_name = params[:feature_name]
    $rollout.clear_feature_data(feature_name)
    $rollout.delete(feature_name)
    Response.represent(message: 'The feature has been removed.')
  end

  params do
    requires :description, type: String, desc: 'The feature description'
    requires :author, type: String, desc: 'The author name'
  end
  post '/:feature_name' do
    feature_name = params[:feature_name]
    percentage = params.fetch(:percentage, 0)
    dogfood = params.fetch(:dogfood, false)
    author = params[:author]
    description =  params[:description]
    members = params[:members]

    current_feature_data = $rollout.multi_get(feature_name).last.data
    history = current_feature_data.fetch('history', [])

    feature_data = {
        members: members,
        description: description,
        dogfood: dogfood,
        updated_at: Time.current
    }

    feature_data[:history] = (history << feature_data.merge({user: author})).last(50)
    feature_data.delete_if { |_, value| value.blank? }

    # new rollout
    if current_feature_data.empty?
      feature_data[:created_at] = Time.current
      feature_data[:created_by] = author
    end

    $rollout.activate_percentage(feature_name, percentage)
    $rollout.set_feature_data(feature_name, feature_data)

    Response.represent(message: 'Feature created successfully!')
  end
end