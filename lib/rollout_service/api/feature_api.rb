module RolloutService
  module API
    class Features < Grape::API

      get '/' do
        features = Config.rollout.features
        features.map! do|feature|
          Models::Feature.find(feature)
        end

        RestfulModels::Response.represent(data: features)
      end


      route_param :feature_name do
        params do
          requires :feature_name, type: Models::Feature
        end
        get '/' do
          feature = params[:feature_name]
          
          RestfulModels::Response.represent(data: feature)
        end

        params do
          requires :user_id, type: Integer, desc: 'The user ID'
          requires :feature_name, type: Models::Feature
        end
        get '/:user_id/active' do
          user_id = params[:user_id].to_i
          feature = params[:feature_name]

          is_active = feature.active?(user_id)

          RestfulModels::Response.represent(data: { active: is_active })
        end

        params do
          requires :feature_name, type: Models::Feature
        end
        delete '/' do
          feature = params[:feature_name]
          feature.delete
          ''
        end

        params do
          requires :description, type: String, desc: 'The feature description'
          requires :feature_name, type: String
        end
        post '/' do
          feature_name = params[:feature_name]
          error! 'Feature is already exist!' if Models::Feature.exist?(feature_name)

          options = {
              name: feature_name,
              percentage: params[:percentage].to_i,
              description:  params[:description],
              author: current_user.name,
              author_mail:  current_user.email,
              created_at: Time.current
          }

          feature = Models::Feature.new(options)

          begin
            feature.save!
            Models::Feature.set_users_to_feature(feature, params[:users])
            RestfulModels::Response.represent(
                message: 'Feature created successfully!',
                data: feature
            )
          rescue => e
            status 500
            RestfulModels::Response.represent(message: "An error has been occurred.\r\n #{e}")
          end
        end

        params do
          requires :feature_name, type: Models::Feature
        end
        patch '/' do
          feature = params[:feature_name]

          options = {
              percentage: params[:percentage].to_i,
              description:  params[:description],
              created_at: Time.current
          }

          # if the feature for some reason had no author, the current user become
          if feature.author.blank?
            options[:author] = current_user.name
            options[:author_mail] = current_user.email
          end

          feature.assign_attributes(options)

          begin
            feature.save!
            Models::Feature.set_users_to_feature(feature, params[:users])
            RestfulModels::Response.represent(
                message: 'Feature updated successfully!',
                data: feature
            )
          rescue => e
            status 500
            RestfulModels::Response.represent(message: "An error has been occurred.\r\n #{e}")
          end
        end
      end
    end
  end
end
