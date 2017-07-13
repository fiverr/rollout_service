module Globals
  extend self

  def environment
    $env = ENV['RACK_ENV'] || 'development'
  end

  def redis
    if ENV['REDIS_URL']
      $redis = Redis.new(url: ENV['REDIS_URL'])
    else
      config =  YAML.load(File.read('./config/redis.yml'))[$env]
      $redis = Redis.new(config)
    end
  end

  def rollout
    $rollout = Rollout.new($redis, use_sets: true)
  end

  def authentication
    config =  YAML.load(File.read('./config/authentication.yml'))[$env] || {}
    $google_oauth_allowed_domain = config[:google_oauth_allowed_domain]
  end

  def setup
    environment
    redis
    rollout
    authentication
  end
end


