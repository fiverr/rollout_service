# class GroupAPI < Grape::API
#
#   get '/:group' do
#     group =  params[:group]
#     members = params[:members].split(',')
#     return Response.new(message: 'error, no members') if members.empty?
#
#     response = $rollout.define_group(group) do |user|
#       user_id = user.to_i
#       members.include?(user_id)
#     end
#
#     Response.represent(message: response)
#   end
#
#
#   post '/:group' do
#     group =  params[:group]
#     members = params[:members]
#     return Response.represent(message: 'error, no members') if members.nil?
#
#     members = members.to_a
#     response = $rollout.define_group(group) do |user|
#       user_id = user.to_i
#       members.include?(user_id)
#     end
#
#     Response.represent(message: response)
#   end
#
#   delete '/:group' do
#     response = $rollout.remove_group(group)
#     Response.represent(message: response)
#   end
# end
