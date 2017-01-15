
module Globals
  extend self


  def environment
    $env = ENV['RACK_ENV'] || 'development'
  end

  def redis
    config = YAML.load_file(File.join('./config/redis.yml'))['environments'][$env]
    $redis = Redis.new(config)
  end

  def rollout
    $rollout = Rollout.new($redis)
  end

  def setup
    environment
    redis
    rollout
  end
end


