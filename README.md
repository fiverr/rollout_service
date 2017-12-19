# Rollout-Service
**A Grape service that expose rollout gem via RESTful endpoints**

This service expose RESTfull endpoints that allows you to perform CRUD operation on [rollout](https://github.com/fetlife/rollout) gem.

This service works great with [Rollout-Dashboard](https://github.com/fiverr/rollout_dashboard) - a beautiful user interface for rollout gem) 

## End-Points Documentation:

### Go to `http://127.0.0.1/api/v1/docs` for auto generated swagger documentation.

### Routes Table
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

## How to set redis configuration?
Edit `./config/redis.yml`

## How to start the service? 
1. Make sure redis is running. 

   For dev environment you can run the command `redis-server`

2. Run `ALLOWED_USERS_EMAILS="user1@gmail.com,user2@gmail.com" bundle exec rackup -p 4000`
Specify proper ALLOWED_USERS_EMAILS and service port. In this example the service will listen on port 4000.
The ALLOWED_USERS_EMAILS env var sets the list of users allowed to use the service via comma-separated list. 
If it's not specified any Google user will be allowed unless you configure domain filter via authentication.yml.

## Authentication

For write operations, the service accept a google oauth token id and validates it.

Besides the token validation, you can also restrict the access to an allowed domain (see `config/authentication.yml`). 

That means that you'll need to authenticate the user before making any write requests. 

Note: The client side authentication already implemented in [Rollout-Dashboard](https://github.com/fiverr/rollout_dashboard)
