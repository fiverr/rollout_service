module RestfulModels
  class Feature < Grape::Entity
    expose :name
    expose :percentage
    expose :history
    expose :description
    expose :dogfood
    expose :author
    expose :members
    expose :created_at
    expose :created_by
  end
end

