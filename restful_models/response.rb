module RestfulModels
   class Response < Grape::Entity
      expose :data, unless: Proc.new {|field| field.nil?}
      expose :message, unless: Proc.new {|field| field.nil?}
   end
end