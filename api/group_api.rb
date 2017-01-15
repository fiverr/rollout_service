class GroupAPI < Grape::API

  post '/:group' do
    group =  params[:group]
    members = params[:members].split(',')
    return Response.new(message: 'error, no members') if members.empty?

    response = $rollout.define_group(group) do |user|
      user_id = user.to_i
      members.include?(user_id)
    end

    Response.new(message: response)
  end

  delete '/:group' do
    response = $rollout.remove_group(group)
    Response.new(message: response)
  end
end
