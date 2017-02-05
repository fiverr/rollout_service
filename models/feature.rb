require 'active_attr'

class Feature
  include ActiveAttr::Model

  MAX_HISTORY_RECORDS = 50

  attribute :name, type: String
  attribute :description, type: String
  attribute :percentage, type: Integer, default: 0
  attribute :last_author, type: String
  attribute :last_author_mail, type: String
  attribute :created_at, type: Date
  attribute :created_by, type: String
  attribute :history, default: []
  attribute :users, default: []

  validates :name,
            :description,
            :percentage,
            :last_author,
            :last_author_mail,
            :created_at,
            :created_by,
            presence: true

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
    rollout.users = users
    users
  end

  def save!
    set_history_attribute
    raise 'Feature is not valid!' unless self.valid?

    $rollout.activate_percentage(self.name, self.percentage)

    feature_data = {
        history: self.history,
        description: self.description,
        last_author: self.last_author,
        last_author_mail: self.last_author_mail,
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

  private

  def set_history_attribute
    self.history << {
        last_author: self.last_author,
        last_author_mail: self.last_author_mail,
        percentage: self.percentage,
        updated_at: Time.current
    }
    self.history = self.history.last(MAX_HISTORY_RECORDS)
  end
end