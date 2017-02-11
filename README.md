# Rollout-Service
**A Grape service that expose rollout gem via RESTful endpoints**

This service expose RESTfull endpoints that allows you to perform CRUD operation on rollout gem.
This service works great with Rollout-Dashboard (user interface for rollout gem) 

# How to set redis configuration?
Edit `./config/redis.yml`

## How to start it? 
run `bundle exec rackup -p :port`

## End-Points Documentation:

* GET /api/v1/features  - Get all features
* GET /api/v1/features/:feature_name/  - Get specific feature by name
* GET /api/v1/features/:feature_name/:user_id/active - Check if feature is active.
* POST /api/v1/features/:feature_name  - Create a new feature
* PATCH /api/v1/features/:feature_name  - Partially update existing feature