#!/bin/bash -e

AWS_ECR_REPO_ACCESS_KEY_ID="{TODO}"
AWS_ECR_REPO_SECRET_ACCESS_KEY="{TODO}"

SPREE_UI_NAME=$ENV-scale-bat-spree-ui
SPREE_UI_IMAGE="569646375982.dkr.ecr.eu-west-2.amazonaws.com/scale-bat-buyer-ui:latest"
SPREE_APP_DISK=1G
SPREE_APP_MEMORY=1G
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
#cf push -k $SPREE_APP_DISK -m $SPREE_APP_MEMORY -i $SPREE_APP_INSTANCES $SPREE_APP_NAME --docker-image $SPREE_APP_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID --vars-file spree-app-vars.yml



#######################
# Restage
#######################
cf restage $SPREE_UI_NAME


##################################
# Set Environment Variables in App
##################################

#cf env scale-bat-buyer-ui-app
#echo $(cf env scale-bat-buyer-ui-app) | jq '.VCAP_SERVICES'

# ECS vars
cf set-env $SPREE_UI_NAME API_HOST "0.0.0.0"
cf set-env $SPREE_UI_NAME BASICAUTH_ENABLED true
cf set-env $SPREE_UI_NAME BASICAUTH_PASSWORD "{TODO}"
cf set-env $SPREE_UI_NAME BASICAUTH_USERNAME "{TODO}"
cf set-env $SPREE_UI_NAME LOGIT_HOSTNAME "{TODO}"
cf set-env $SPREE_UI_NAME LOGIT_REMOTE_PORT 21976
cf set-env $SPREE_UI_NAME PORT 8080 #PORT CANNOT BE SET - but it will be available
#cf set-env $SPREE_UI_NAME ROLLBAR_ACCESS_TOKEN "{TODO}"
cf set-env $SPREE_UI_NAME ROLLBAR_ENV "SANDBOX"
cf set-env $SPREE_UI_NAME SESSION_COOKIE_SECRET	"{TODO}"
cf set-env $SPREE_UI_NAME SPREE_API_HOST "https://scale-bat-spree-sb-app-tb.london.cloudapps.digital" #Need to make APP private?
cf set-env $SPREE_UI_NAME SPREE_IMAGE_HOST "https://scale-bat-spree-sb-app-tb.london.cloudapps.digital"


# S3 vars
cf set-env $SPREE_UI_NAME DOCUMENTS_TERMS_AND_CONDITIONS_URL "https://purchasingplatform.crowncommercial.gov.uk/"
cf set-env $SPREE_UI_NAME ROLLBAR_CLIENT_ACCESS_TOKEN "{TODO}"
cf set-env $SPREE_UI_NAME PAPERTRAIL_HOSTNAME "{TODO}"
cf set-env $SPREE_UI_NAME PAPERTRAIL_REMOTE_PORT 19364

#######################
# Restage (Again ?)
#######################
cf restage $SPREE_UI_NAME



#######################
# Buyer UI App
#######################
cf push -k 1G -m 1G -i $SPREE_APP_INSTANCES $SPREE_UI_NAME --docker-image $SPREE_UI_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID

