module Globals
  extend self

  def environment
    $env = ENV['RACK_ENV'] || 'development'
  end

  def redis
    config =  YAML.load(File.read('./config/redis.yml'))[$env]
    $redis = Redis.new(config)
  end

  def rollout
    $rollout = Rollout.new($redis, use_sets: true)
  end

  def setup
    environment
    redis
    rollout
  end
end


