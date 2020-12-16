#!/bin/bash

export CF_DOCKER_PASSWORD=$AWS_ECR_REPO_SECRET_ACCESS_KEY

#######################
# Spree App
#######################
cf push -k $DISK_SPREE_UI -m $MEMORY_SPREE_UI -i $INSTANCES_SPREE_UI $(expand_var $APP_NAME_SPREE_UI) \
  --docker-image $DOCKER_IMAGE_SPREE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID --no-start

#######################
# Bind to Services
#######################
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_PG)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_ES)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_REDIS_CACHE)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_REDIS_SIDEKIQ)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_S3_SPREE_IMAGES)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_S3_SPREE_CNET)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $SERVICE_NAME_S3_SPREE_PRODUCTS)

# UPS
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $UPS_NAME_GENERAL)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $UPS_NAME_ROLLBAR)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $UPS_NAME_LOGITIO)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $UPS_NAME_SENDGRID)
cf bind-service $(expand_var $APP_NAME_SPREE_UI) $(expand_var $UPS_NAME_NEWRELIC)

##################################
# Set Environment Variables in App
##################################

#cf env scale-bat-buyer-ui-app
#echo $(cf env scale-bat-buyer-ui-app) | jq '.VCAP_SERVICES'

# Static / miscellaneous
cf set-env $(expand_var $APP_NAME_SPREE_UI) APP_DOMAIN "$(expand_var $APP_NAME_SPREE_UI).london.cloudapps.digital"
cf set-env $(expand_var $APP_NAME_SPREE_UI) AWS_REGION "$AWS_REGION"
cf set-env $(expand_var $APP_NAME_SPREE_UI) S3_REGION "$AWS_REGION"
cf set-env $(expand_var $APP_NAME_SPREE_UI) BASICAUTH_ENABLED "true"

# S3 Bucket names - TODO: Will ALL change with SINF-224
cf set-env $(expand_var $APP_NAME_SPREE_UI) PRODUCTS_IMPORT_BUCKET $(expand_var $SERVICE_NAME_S3_SPREE_PRODUCTS)
cf set-env $(expand_var $APP_NAME_SPREE_UI) S3_BUCKET_NAME $(expand_var $SERVICE_NAME_S3_SPREE_IMAGES)
cf set-env $(expand_var $APP_NAME_SPREE_UI) CNET_PRODUCTS_IMPORT_BUCKET $(expand_var $SERVICE_NAME_S3_SPREE_CNET)

#######################
# Restage and start
#######################
cf restage $(expand_var $APP_NAME_SPREE_UI)

#######################
# Buyer UI App
#######################
# cf push -k $SPREE_APP_DISK -m $SPREE_APP_MEMORY -i $SPREE_APP_INSTANCES $(expand_var $APP_NAME_SPREE_UI) --docker-image $SPREE_APP_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID
