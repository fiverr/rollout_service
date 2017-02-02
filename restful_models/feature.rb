module RestfulModels
  class Feature < Grape::Entity
    expose :name ,unless: Proc.new {|field| field.nil?}
    expose :percentage ,unless: Proc.new {|field| field.nil?}
    expose :history ,unless: Proc.new {|field| field.nil?}
    expose :description ,unless: Proc.new {|field| field.nil?}
    expose :last_author , unless: Proc.new {|field| field.nil?}
    expose :last_author_mail , unless: Proc.new {|field| field.nil?}
    expose :users ,unless: Proc.new {|field| field.nil?}
    expose :created_at ,unless: Proc.new {|field| field.nil?}
    expose :created_by ,unless: Proc.new {|field| field.nil?}
  end
end