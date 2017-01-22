require 'active_model'

class Feature
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Validations

  MAX_HISTORY_RECORDS = 50

  validates :name,
            :description,
            :percentage,
            :author,
            :created_at,
            :created_by,
            presence: true

  validate :validate

  attr_accessor :history,
                :description,
                :percentage,
                :author,
                :users,
                :name,
                :created_at,
                :created_by

  def initialize(attributes)
    super(attributes)
    self.set_default_values
  end

  def self.find(name)
    return nil unless exist?(name)

    feature = $rollout.get(name)
    feature_data = feature.data.symbolize_keys!
    feature_data.delete_if {|key, _| !self.method_defined?(key)}

    feature_data.merge!({
     name: feature.name,
     percentage: feature.percentage,
     users: feature.users
    })
    self.new(feature_data)
  end

  def self.exist?(name)
    @features ||= $rollout.features
    @features.include?(name.to_sym)
  end

  def save!
    self.set_history_attribute
    Throw 'Feature is not valid!' unless self.valid?

    $rollout.activate_percentage(self.name, self.percentage)

    feature_data = {
        history: self.history,
        description: self.description,
        author: self.author,
        created_at: self.created_at,
        created_by: self.created_by,
    }

    feature_data.delete_if { |_, value| value.blank? }
    $rollout.set_feature_data(self.name, feature_data)
  end

  def active?(user_id)
    $rollout.active?(self.name, user_id)
  end

  def delete
    $rollout.clear_feature_data(self.name)
    $rollout.delete(self.name)
  end

  def add_user(user_id)
    $rollout.activate_user(self.name, user_id)
  end

  def remove_user(user_id)
    $rollout.deactivate_user(self.name, user_id)
  end

  def set_default_values
    self.history ||= []
    self.users ||= []
    self.percentage ||= 0
  end

  def set_history_attribute
    self.history << {
        author: self.author,
        percentage: self.percentage,
        updated_at: Time.current
    }
    self.history = self.history.last(MAX_HISTORY_RECORDS)
  end

  def assign_attributes(options = {})
    options.delete_if { |_, value| value.blank? }
    super(options)
  end


  private

  def validate
    errors.add(:base, 'Wrong data type') unless validate_data_types
  end

  def validate_data_types
    self.percentage.is_a?(Numeric) &&
        self.users.is_a?(Array) &&
        self.history.is_a?(Array)
  end
end