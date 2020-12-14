#!/bin/bash

##################
# Postgres Service
##################
cf create-service postgres $SERVICE_PLAN_PG $(resolve_env_property ${SERVICE_NAME_PG})

#######################
# Elasticsearch Service
#######################
cf create-service elasticsearch $SERVICE_PLAN_ES $(resolve_env_property ${SERVICE_NAME_ES})

###############
# Redis Services (frontend cache / sidekiq)
###############
cf create-service redis $SERVICE_PLAN_REDIS_CACHE $(resolve_env_property ${SERVICE_NAME_REDIS_CACHE})
cf create-service redis $SERVICE_PLAN_REDIS_SIDEKIQ $(resolve_env_property ${SERVICE_NAME_REDIS_SIDEKIQ})

###################
# Memcached Service
###################
# TBD -https://docs.cloud.service.gov.uk/deploying_services/user_provided_services/#user-provided-backing-services?

#############
# S3 Services
#############
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_IMAGES)
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_CNET)
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_PRODUCTS)

#############
# User-Provided Services
# Encapsulates external service details including credentials. Prompts for user input.
#############
if [[ $PROVISION_UPS ]]; then
  echo "Enter Rollbar service details as prompted:"
  cf cups $(resolve_env_property $UPS_NAME_ROLLBAR) -p "access-token, env"

  echo "Enter logit.io service details as prompted:"
  cf cups $(resolve_env_property $UPS_NAME_LOGITIO) -p "host, port"

  echo "Enter Sendgrid service details as prompted:"
  cf cups $(resolve_env_property $UPS_NAME_SENDGRID) -p "username, password"

  echo "Enter New Relic service details as prompted:"
  cf cups $(resolve_env_property $UPS_NAME_NEWRELIC) -p "appname, license-key, enabled"
fi
