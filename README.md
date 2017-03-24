# Rollout-Service
**A Grape service that expose rollout gem via RESTful endpoints**

This service expose RESTfull endpoints that allows you to perform CRUD operation on [rollout](https://github.com/fetlife/rollout) gem.

This service works great with [Rollout-Dashboard](https://github.com/fiverr/rollout_dashboard) - a beautiful user interface for rollout gem)

## Deploy

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

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

# FAQ

# How to set redis configuration?

Add the `REDIS_URL` environment variable. On *nix systems you can do the following:
`export REDIS_URL="redis://username:password@redis.url:port"`

# How to limit google authentication to a single domain?

Add the `GOOGLE_OAUTH_ALLOWED_DOMAIN` environment variable. On *nix systems you can do the following:
`export GOOGLE_OAUTH_ALLOWED_DOMAIN="fiverr.com"`

## How to start the service?
run `bundle exec rackup -p :port`
