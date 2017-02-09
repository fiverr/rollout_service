class SystemAPI < Grape::API

  get '/ping' do
    "Pong from rollout-service, current time is #{Time.to_s}"
  end
end