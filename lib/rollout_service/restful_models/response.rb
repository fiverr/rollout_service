module RolloutService
   module RestfulModels
      class Response < Grape::Entity
         expose :data, unless: Proc.new {|field| field.blank?}
         expose :message, if: ->(response, _) { response[:data].blank? }
      end
   end
end