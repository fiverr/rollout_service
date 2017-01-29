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
    $rollout = Rollout.new($redis)
  end

  def white_list_ips
    $white_list_ips = YAML.load(File.open('./config/white_list_ips.yml'))[$env] || []
  end

  def setup
    environment
    redis
    rollout
    white_list_ips
  end
end


