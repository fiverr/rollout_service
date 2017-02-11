# Rollout-Service
**A Grape service that expose rollout gem via RESTful endpoints**

This service expose RESTfull endpoints that allows you to perform CRUD operation on rollout gem.

This service works great with [Rollout-Dashboard](https://github.com/fiverr/rollout_dashboard) (a user interface for rollout gem) 

# How to set redis configuration?
Edit `./config/redis.yml`

## How to start the service? 
run `bundle exec rackup -p :port`

## End-Points Documentation:
* Get all features: 
`GET /api/v1/features`

* Get specific feature by name: 
`GET /api/v1/features/:feature_name`

* Check if feature is active: 
`GET /api/v1/features/:feature_name/:user_id/active`

* Create a new feature: 
`POST /api/v1/features/:feature_name`

* Partially update existing feature: 
`PATCH /api/v1/features/:feature_name`
