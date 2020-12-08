#!/bin/bash -e

#cf marketplace -s postgres
REDIS_PLAN=tiny-5.x
PG_PLAN=tiny-unencrypted-9.5
# actual plan (paid) for DEV/INT should be: PG_PLAN=medium-ha-11
ES_PLAN=tiny-7.x 

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
cf create-service postgres $PG_PLAN $PG_SERVICE_NAME

#######################
# Elasticsearch Service
#######################
cf create-service elasticsearch $ES_PLAN $ES_SERVICE_NAME

###############
# Redis Service
###############
cf create-service redis $REDIS_PLAN $REDIS_SERVICE_NAME

###################
# Memcached Service
###################
# TBD -https://docs.cloud.service.gov.uk/deploying_services/user_provided_services/#user-provided-backing-services? 

#############
# S3 Services
#############
cf create-service aws-s3-bucket default $S3_CNET_SERVICE_NAME
cf create-service aws-s3-bucket default $S3_FEED_SERVICE_NAME
cf create-service aws-s3-bucket default $S3_IMAGES_SERVICE_NAME
cf create-service aws-s3-bucket default $S3_PRODUCTS_SERVICE_NAME