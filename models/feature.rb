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
            :author_mail,
            :created_at,
            :created_by,
            presence: true

  validate :validate

  attr_accessor :history,
                :description,
                :percentage,
                :author,
                :users,
                :author_mail,
                :name,
                :created_at,
                :created_by

  def initialize(attributes)
    super(attributes)
    set_default_values
  end

  def self.parse(name)
      instance = find(name)
      raise 'Feature is not exist' if instance.nil?
      instance
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
    features = $rollout.features
    features.include?(name.to_sym)
  end

  def self.set_users_to_feature(rollout, users)
    return if users.nil? || rollout.nil?
    users = users.to_a

    current_active_users = rollout.users
    users_to_remove = current_active_users - users

    $rollout.deactivate_users(rollout.name ,users_to_remove)
    $rollout.activate_users(rollout.name ,users)
  end

  def save!
    set_history_attribute
    raise 'Feature is not valid!' unless self.valid?

    $rollout.activate_percentage(self.name, self.percentage)

    feature_data = {
        history: self.history,
        description: self.description,
        author: self.author,
        author_mail: self.author_mail,
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
    $rollout.delete(self.name)
  end

  def add_user(user_id)
    $rollout.activate_user(self.name, user_id)
  end

  def remove_user(user_id)
    $rollout.deactivate_user(self.name, user_id)
  end

  def assign_attributes(options = {})
    return nil unless options.is_a?(Hash)

    options.delete_if { |_, value| value.blank? }
    super(options)
  end

  private

  def set_default_values
    self.history ||= []
    self.users ||= []
    self.percentage ||= 0
  end

  def validate
    errors.add(:base, 'Wrong data type') unless validate_data_types
  end

  def validate_data_types
    self.percentage.is_a?(Numeric) &&
        self.users.is_a?(Array) &&
        self.history.is_a?(Array)
  end

  def set_history_attribute
    self.history << {
        author: self.author,
        percentage: self.percentage,
        updated_at: Time.current
    }
    self.history = self.history.last(MAX_HISTORY_RECORDS)
  end
end