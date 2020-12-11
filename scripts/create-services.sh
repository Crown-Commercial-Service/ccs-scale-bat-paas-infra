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
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_CONFIG)
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_IMAGES)
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_CNET)
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_FEED)
cf create-service aws-s3-bucket default $(resolve_env_property $SERVICE_NAME_S3_SPREE_PRODUCTS)
