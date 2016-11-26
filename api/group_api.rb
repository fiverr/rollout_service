class GroupAPI < Grape::API

  post '/:group' do
    group =  params[:group]
    members = params[:members].split(',')
    return Response.new if members.empty?

    response = $rollout.define_group(group) do |user|
      user_id = user.is_a?(Numeric) ? user : user.id
      members.include?(user_id)
    end

    Response.new(response)
  end

  delete '/:group' do
    response = $rollout.remove_group(group)
    Response.new(response)
  end
end
