module RestfulModels
   class Response < Grape::Entity
      expose :data, unless: { data: 'nil' }
      expose :message, unless:{ message: 'nil' }
   end
end