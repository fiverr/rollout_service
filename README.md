# Rollout-Service
**Rack app that exposes rollout gem API via RESTful endpoints**

This Rack app expose RESTfull endpoints that allows you to perform CRUD operation on [rollout](https://github.com/fetlife/rollout) gem.

This service works great with [Rollout-Dashboard](https://github.com/fiverr/rollout_dashboard) - a beautiful user interface for rollout gem) 

## How to use this app?
1. Pass a redis instance to the app
```ruby
redis = Redis.new
RolloutService::Config::configure do |config|
  config.redis = redis
end
```

2. Map an a route to the app:
```ruby
map '/api/v1' do
  run RolloutService::Service
end
```
## I want to run this service a stand alone service, how do I do that?
1. Include the gem 'rack-app' & 'rollout_service' in your project.
2. create a file named `config.ru`

```ruby
# Add here system configuration and initializations  

# Create a redis instance 
redis = Redis.new

# Pass the instance to rollout service
RolloutService::Config::configure do |config|
  config.redis = redis
end

# Map a route to the app
map '/api/v1' do
  run RolloutService::Service
end
```

## End-Points Documentation:

| Description   | END POINT     |
| ------------- | ------------- |
| Get all features  | GET /api/v1/features  |
| Get specific feature by name  | GET /api/v1/features/:feature_name  |
| Get specific feature by name  | GET /api/v1/features/:feature_name  |
| Check if feature is active  | GET /api/v1/features/:feature_name/:user_id/active  |
| Create a new feature  | POST /api/v1/features/:feature_name  |
| Partially update existing feature  | PATCH /api/v1/features/:feature_name  |
| Delete a feature  | DELETE /api/v1/features/:feature_name  |
