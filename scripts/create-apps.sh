#!/bin/bash -e

AWS_ECR_REPO_ACCESS_KEY_ID="{TODO}"
AWS_ECR_REPO_SECRET_ACCESS_KEY="{TODO}"

SPREE_APP_NAME=$ENV-scale-bat-spree-app
SPREE_APP_IMAGE="569646375982.dkr.ecr.eu-west-2.amazonaws.com/scale-bat-spree:latest"
SPREE_APP_DISK=3G
SPREE_APP_MEMORY=4G
SPREE_APP_INSTANCES=1

# See services script - these names can/will/should change
PG_SERVICE_NAME=scale-bat-pg-$ENV-service
ES_SERVICE_NAME=scale-bat-es-$ENV-service
REDIS_SERVICE_NAME=scale-bat-redis-$ENV-service
S3_CNET_SERVICE_NAME=cnet-spree-$ENV-staging
S3_FEED_SERVICE_NAME=feed-spree-$ENV-staging
S3_IMAGES_SERVICE_NAME=spree-$ENV-staging
S3_PRODUCTS_SERVICE_NAME=spree-$ENV-products-import

export CF_DOCKER_PASSWORD=$AWS_ECR_REPO_SECRET_ACCESS_KEY

#######################
# Spree App
#######################
cf push -k $SPREE_APP_DISK -m $SPREE_APP_MEMORY -i $SPREE_APP_INSTANCES $SPREE_APP_NAME --docker-image $SPREE_APP_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID --vars-file spree-app-vars.yml

#######################
# Bind to Services
#######################
cf bind-service $SPREE_APP_NAME $PG_SERVICE_NAME
cf bind-service $SPREE_APP_NAME $ES_SERVICE_NAME
cf bind-service $SPREE_APP_NAME $REDIS_SERVICE_NAME
cf bind-service $SPREE_APP_NAME $S3_CNET_SERVICE_NAME
cf bind-service $SPREE_APP_NAME $S3_FEED_SERVICE_NAME
cf bind-service $SPREE_APP_NAME $S3_IMAGES_SERVICE_NAME
cf bind-service $SPREE_APP_NAME $S3_PRODUCTS_SERVICE_NAME

#######################
# Restage
#######################
cf restage $SPREE_APP_NAME


##################################
# Set Environment Variables in App
##################################

#cf env scale-bat-buyer-ui-app
#echo $(cf env scale-bat-buyer-ui-app) | jq '.VCAP_SERVICES'

# Dynamic - from Services (VCAP_SERVICES)
cf set-env $SPREE_APP_NAME DB_HOST "{TODO}"
cf set-env $SPREE_APP_NAME DB_NAME "{TODO}"
cf set-env $SPREE_APP_NAME DB_USERNAME "{TODO}"
cf set-env $SPREE_APP_NAME DB_PASSWORD "{TODO}"
cf set-env $SPREE_APP_NAME ELASTICSEARCH_URL "{TODO}"
cf set-env $SPREE_APP_NAME MEMCACHED_ENDPOINT "{TODO}"
cf set-env $SPREE_APP_NAME REDIS_URL "{TODO}"

# Static
cf set-env $SPREE_APP_NAME APP_DOMAIN "$SPREE_APP_NAME.london.cloudapps.digital"
cf set-env $SPREE_APP_NAME AWS_REGION "eu-west-2"
cf set-env $SPREE_APP_NAME BASICAUTH_ENABLED "{TODO}"
cf set-env $SPREE_APP_NAME BASICAUTH_USERNAME "{TODO}"
cf set-env $SPREE_APP_NAME BASICAUTH_PASSWORD "test!"
cf set-env $SPREE_APP_NAME SECRET_KEY_BASE "{TODO}"
cf set-env $SPREE_APP_NAME PRODUCTS_IMPORT_BUCKET $S3_PRODUCTS_SERVICE_NAME
cf set-env $SPREE_APP_NAME S3_REGION "eu-west-2"
cf set-env $SPREE_APP_NAME S3_BUCKET_NAME $S3_IMAGES_SERVICE_NAME
cf set-env $SPREE_APP_NAME AWS_ACCESS_KEY "{TODO}"
cf set-env $SPREE_APP_NAME SECRET_ACCESS_KEY "{TODO}"
cf set-env $SPREE_APP_NAME SIDEKIQ_USERNAME "{TODO}"
cf set-env $SPREE_APP_NAME SIDEKIQ_PASSWORD "{TODO}"

# Third Party Apps
cf set-env $SPREE_APP_NAME ROLLBAR_ACCESS_TOKEN "{TODO}"
cf set-env $SPREE_APP_NAME ROLLBAR_ENV $ENV
cf set-env $SPREE_APP_NAME SENDGRID_USERNAME "{TODO}"
cf set-env $SPREE_APP_NAME SENDGRID_PASSWORD "{TODO}"
cf set-env $SPREE_APP_NAME FLIPPER_USERNAME "{TODO}"
cf set-env $SPREE_APP_NAME FLIPPER_PASSWORD "{TODO}"
cf set-env $SPREE_APP_NAME NEW_RELIC_LICENCE_KEY "{TODO}"
cf set-env $SPREE_APP_NAME NEW_RELIC_APP_NAME "{TODO}"
cf set-env $SPREE_APP_NAME NEW_RELIC_AGENT_ENABLED "{TODO}"

#######################
# Restage (Again ?)
#######################
cf restage $SPREE_APP_NAME


#######################
# Buyer UI App
#######################
cf push -k $SPREE_APP_DISK -m $SPREE_APP_MEMORY -i $SPREE_APP_INSTANCES $SPREE_APP_NAME --docker-image $SPREE_APP_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID
