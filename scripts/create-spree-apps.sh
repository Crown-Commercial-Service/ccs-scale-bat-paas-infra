#!/bin/bash -e

AWS_ECR_REPO_ACCESS_KEY_ID="{TODO}"
AWS_ECR_REPO_SECRET_ACCESS_KEY="{TODO}"

export CF_DOCKER_PASSWORD=$AWS_ECR_REPO_SECRET_ACCESS_KEY

#######################
# Spree App
#######################
cf push -k $DISK_SPREE_UI -m $MEMORY_SPREE_UI -i $INSTANCES_SPREE_UI $APP_NAME_SPREE_UI \
  --docker-image $DOCKER_IMAGE_SPREE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID --no-start

#######################
# Bind to Services
#######################
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_PG
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_ES
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_REDIS_CACHE
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_REDIS_SIDEKIQ
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_S3_SPREE_IMAGES
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_S3_SPREE_CNET
cf bind-service $APP_NAME_SPREE_UI $SERVICE_NAME_S3_SPREE_PRODUCTS

##################################
# Set Environment Variables in App
##################################

#cf env scale-bat-buyer-ui-app
#echo $(cf env scale-bat-buyer-ui-app) | jq '.VCAP_SERVICES'

# Dynamic - from Services (VCAP_SERVICES)
# cf set-env $APP_NAME_SPREE_UI DB_HOST "{TODO}"
# cf set-env $APP_NAME_SPREE_UI DB_NAME "{TODO}"
# cf set-env $APP_NAME_SPREE_UI DB_USERNAME "{TODO}"
# cf set-env $APP_NAME_SPREE_UI DB_PASSWORD "{TODO}"
# cf set-env $APP_NAME_SPREE_UI ELASTICSEARCH_URL "{TODO}"
# cf set-env $APP_NAME_SPREE_UI MEMCACHED_ENDPOINT "{TODO}"
# cf set-env $APP_NAME_SPREE_UI REDIS_URL "{TODO}"

# From spree.env:
# SIDEKIQ_USERNAME=admin
# SIDEKIQ_PASSWORD={TODO}
# SENDGRID_USERNAME={TODO}
# SENDGRID_PASSWORD={TODO}
# AWS_REGION=eu-west-2
# AWS_ACCESS_KEY_ID={TODO}
# AWS_SECRET_ACCESS_KEY={TODO}
# S3_REGION=eu-west-2
# NEW_RELIC_LICENSE_KEY={TODO}
# NEW_RELIC_APP_NAME="BaT Spree DEV"
# NEW_RELIC_AGENT_ENABLED=true

# Static
cf set-env $APP_NAME_SPREE_UI APP_DOMAIN "$APP_NAME_SPREE_UI.london.cloudapps.digital"
cf set-env $APP_NAME_SPREE_UI AWS_REGION "eu-west-2"
cf set-env $APP_NAME_SPREE_UI BASICAUTH_ENABLED "{TODO}"
cf set-env $APP_NAME_SPREE_UI BASICAUTH_USERNAME "{TODO}"
cf set-env $APP_NAME_SPREE_UI BASICAUTH_PASSWORD "test!"
cf set-env $APP_NAME_SPREE_UI SECRET_KEY_BASE "{TODO}"
cf set-env $APP_NAME_SPREE_UI PRODUCTS_IMPORT_BUCKET $S3_PRODUCTS_SERVICE_NAME
cf set-env $APP_NAME_SPREE_UI S3_REGION "eu-west-2"
cf set-env $APP_NAME_SPREE_UI S3_BUCKET_NAME $S3_IMAGES_SERVICE_NAME
cf set-env $APP_NAME_SPREE_UI AWS_ACCESS_KEY "{TODO}"
cf set-env $APP_NAME_SPREE_UI SECRET_ACCESS_KEY "{TODO}"
cf set-env $APP_NAME_SPREE_UI SIDEKIQ_USERNAME "{TODO}"
cf set-env $APP_NAME_SPREE_UI SIDEKIQ_PASSWORD "{TODO}"

# Third Party Apps
cf set-env $APP_NAME_SPREE_UI ROLLBAR_ACCESS_TOKEN "{TODO}"
cf set-env $APP_NAME_SPREE_UI ROLLBAR_ENV $ENV
cf set-env $APP_NAME_SPREE_UI SENDGRID_USERNAME "{TODO}"
cf set-env $APP_NAME_SPREE_UI SENDGRID_PASSWORD "{TODO}"
cf set-env $APP_NAME_SPREE_UI FLIPPER_USERNAME "{TODO}"
cf set-env $APP_NAME_SPREE_UI FLIPPER_PASSWORD "{TODO}"
cf set-env $APP_NAME_SPREE_UI NEW_RELIC_LICENCE_KEY "{TODO}"
cf set-env $APP_NAME_SPREE_UI NEW_RELIC_APP_NAME "{TODO}"
cf set-env $APP_NAME_SPREE_UI NEW_RELIC_AGENT_ENABLED "{TODO}"

#######################
# Restage and start
#######################
cf restage $APP_NAME_SPREE_UI

#######################
# Buyer UI App
#######################
# cf push -k $SPREE_APP_DISK -m $SPREE_APP_MEMORY -i $SPREE_APP_INSTANCES $APP_NAME_SPREE_UI --docker-image $SPREE_APP_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID
