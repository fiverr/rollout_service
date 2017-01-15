class Response < Grape::Entity
   expose :data
   expose :message, unless:{ message: nil}
end