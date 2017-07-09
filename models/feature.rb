require 'active_attr'

class Feature
  include ActiveAttr::Model

  MAX_HISTORY_RECORDS = 50

  attribute :name, type: String
  attribute :description, type: String
  attribute :percentage, type: Integer, default: 0
  attribute :author, type: String
  attribute :author_mail, type: String
  attribute :created_at, type: Date
  attribute :history, default: []
  attribute :users, default: []
  attribute :groups, default: []

  validates :name,
            :description,
            :percentage,
            :created_at,
            :author,
            :author_mail,
            presence: true

  def self.parse(name)
      instance = find(name)
      raise 'Feature is not exist' if instance.nil?
      instance
  end

  def self.find(name)
    return nil unless exist?(name)

    feature = $rollout.get(name)
    feature_data = feature.data.deep_symbolize_keys!

    feature_data.merge!({
     name: feature.name,
     percentage: feature.percentage,
     users: feature.users,
     groups: feature.groups
    })

    feature_data[:author] = feature_data[:last_author] if feature_data[:author].blank?
    feature_data[:author_mail] = feature_data[:last_author_mail] if feature_data[:author_mail].blank?

    if feature_data[:history].present?
      feature_data[:history] = feature_data[:history].map do |record|
        record[:author] = record[:last_author] if record[:author].blank?
        record[:author_mail] = record[:last_author_mail] if record[:author_mail].blank?
        record
      end
    end

    feature_data.delete_if {|key, _| !self.method_defined?(key)}

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

  def self.set_groups_to_feature(rollout_feature, groups)
    return if groups.nil? || rollout_feature.nil?
    groups = groups.to_a

    current_active_groups = rollout_feature.groups
    groups_to_remove = current_active_groups - groups
    groups_to_remove.each { |g| $rollout.deactivate_group(rollout_feature.name ,g) }
    groups.each { |g| $rollout.activate_group(rollout_feature.name ,g) }
    rollout_feature.groups = groups
    groups
  end

  def save!
    return unless $current_user.present?

    set_history_attribute
    raise 'Feature is not valid!' unless self.valid?

    $rollout.activate_percentage(self.name, self.percentage)

    feature_data = {
        history: self.history,
        description: self.description,
        author: self.author,
        author_mail: self.author_mail,
        created_at: self.created_at
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
    last_record = history.last
    return if last_record.present? && last_record[:percentage] == self.percentage

    self.history << {
        author: $current_user.name,
        author_mail: $current_user.mail,
        percentage: self.percentage,
        updated_at: Time.current
    }
    self.history = self.history.last(MAX_HISTORY_RECORDS)
  end
end