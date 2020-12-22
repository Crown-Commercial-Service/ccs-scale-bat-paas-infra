#!/bin/bash

##################
# Postgres Service
##################
cf delete-service -f $(expand_var ${SERVICE_NAME_PG})

#######################
# Elasticsearch Service
#######################
cf delete-service -f $(expand_var ${SERVICE_NAME_ES})

###############
# Redis Services (frontend cache / sidekiq)
###############
cf delete-service -f $(expand_var ${SERVICE_NAME_REDIS_CACHE})
cf delete-service -f $(expand_var ${SERVICE_NAME_REDIS_SIDEKIQ})

#############
# S3 Services (NB: Objects must be deleted first)
#############
cf delete-service -f $(expand_var $SERVICE_NAME_S3_SPREE_IMAGES)
cf delete-service -f $(expand_var $SERVICE_NAME_S3_SPREE_CNET)
cf delete-service -f $(expand_var $SERVICE_NAME_S3_SPREE_PRODUCTS)

#############
# User-Provided Services
#############

cf delete-service -f $(expand_var $UPS_NAME_NEWRELIC)
cf delete-service -f $(expand_var $UPS_NAME_ROLLBAR)
cf delete-service -f $(expand_var $UPS_NAME_LOGITIO)
cf delete-service -f $(expand_var $UPS_NAME_SENDGRID)
cf delete-service -f $(expand_var $UPS_NAME_GENERAL)
cf delete-service -f $(expand_var $UPS_NAME_GENERAL_CLIENT)
cf delete-service -f $(expand_var $UPS_NAME_PAPERTRAIL)
