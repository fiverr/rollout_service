require 'active_model'

class Feature
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::AttributeAssignment

  validates :name,
            :description,
            :percentage,
            :author,
            :created_at,
            :created_by,
            presence: true

  validates :dogfood, inclusion: {in: [true, false]}
  validate :validate

  attr_accessor :history,
                :description,
                :percentage,
                :dogfood,
                :author,
                :members,
                :name,
                :created_at,
                :created_by

  def initialize(attributes)
    super(attributes)
    self.set_default_values
  end

  def self.find(name)
    feature = $rollout.get(name)
    feature_data = feature.data.symbolize_keys!
    feature_data.delete_if {|key, _| !self.method_defined?(key)}

    feature_data.merge!({
     name: feature.name,
     percentage: feature.percentage
    })
    self.new(feature_data)
  end

  def save!
    Throw 'Feature is not valid!' unless self.valid?
    $rollout.activate_percentage(self.name, self.percentage)

    feature_data = {
        history: self.history,
        description: self.description,
        dogfood: self.dogfood,
        author: self.author,
        members: self.members,
        created_at: self.created_at,
        created_by: self.created_by,
    }

    feature_data.delete_if { |_, value| value.blank? }
    $rollout.set_feature_data(self.name, feature_data)
  end

  def active?(user_id)
    return true if $rollout.active?(self.name, user_id)
    self.members.include?(user_id)
  end

  def delete
    $rollout.clear_feature_data(self.name)
    $rollout.delete(self.name)
  end

  def set_default_values
    self.history ||= []
    self.members ||= []
    self.dogfood ||= false
    self.percentage ||= 0
  end

  private

  def validate
    errors.add(:base, 'Wrong data type') unless validate_data_types
  end

  def validate_data_types
    self.percentage.is_a?(Numeric) &&
        %w(true false).include?(self.dogfood.to_s) &&
        self.members.is_a?(Array) &&
        self.history.is_a?(Array)
  end

end