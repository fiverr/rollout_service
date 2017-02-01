module Globals
  extend self

  def environment
    $env = ENV['RACK_ENV'] || 'development'
  end

  def redis
    config =  {
        host: ENV['redis_host'] || '127.0.0.1',
        port: ENV['redis_port'] || 6379
    }
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


