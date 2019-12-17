module RolloutService
  module Config
    extend self
    attr_accessor :rollout, :redis

    def configure
      yield self
      raise 'You must provide a redis instance' if redis.blank?

      self.rollout ||= Rollout.new(redis, use_sets: true)
    end
  end
end

