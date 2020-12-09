#!/bin/bash -e


ENV=sb

# Note: names to be decided - maybe we need to check with TechOps
# Note: 'scale', 'bat', 'env' seem a bit redundant in names, but may be helpful under certain circumstance - to discuss
PG_SERVICE_NAME=scale-bat-pg-$ENV-service
ES_SERVICE_NAME=scale-bat-es-$ENV-service
REDIS_SERVICE_NAME=scale-bat-redis-$ENV-service
# Note: S3 buckets reflect current names - suggest changing these
S3_CNET_SERVICE_NAME=cnet-spree-$ENV-staging
S3_FEED_SERVICE_NAME=feed-spree-$ENV-staging
S3_IMAGES_SERVICE_NAME=spree-$ENV-staging
S3_PRODUCTS_SERVICE_NAME=spree-$ENV-products-import

##################
# Postgres Service
##################
cf delete-service $PG_SERVICE_NAME

#######################
# Elasticsearch Service
#######################
cf delete-service $ES_SERVICE_NAME

###############
# Redis Service
###############
cf delete-service $REDIS_SERVICE_NAME

###################
# Memcached Service
###################
# TBD -https://docs.cloud.service.gov.uk/deploying_services/user_provided_services/#user-provided-backing-services? 

#############
# S3 Services
#############
cf delete-service $S3_CNET_SERVICE_NAME
cf delete-service $S3_FEED_SERVICE_NAME
cf delete-service $S3_IMAGES_SERVICE_NAME
cf delete-service $S3_PRODUCTS_SERVICE_NAME