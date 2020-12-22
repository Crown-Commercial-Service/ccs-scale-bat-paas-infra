#!/bin/bash

#######################
# BaT Client UI
#######################
cf push -k $DISK_BAT_BUYER_UI -m $MEMORY_BAT_BUYER_UI -i $INSTANCES_BAT_BUYER_UI $APP_NAME \
  --docker-image $DOCKER_IMAGE_BAT_BUYER_UI --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID \
  -c "npm run server" --no-start


cf add-network-policy $APP_NAME $(expand_var $APP_NAME_SPREE_UI) -s $SPACE -o $ORG --protocol tcp --port 3000

#######################
# Bind to Services
#######################
# UPS
cf bind-service $APP_NAME $(expand_var $UPS_NAME_GENERAL_CLIENT)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_ROLLBAR)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_LOGITIO)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_PAPERTRAIL)

##################################
# Set Environment Variables in App
##################################

cf set-env $APP_NAME SPREE_API_HOST "http://$(expand_var $APP_NAME_SPREE_UI).apps.internal:3000"
cf set-env $APP_NAME SPREE_IMAGE_HOST	"https://$(expand_var $APP_NAME_SPREE_UI).london.cloudapps.digital"

# TODO: Improve the sed command to remove need to prefix with additional '{' char
VCAP_SERVICES="{$(cf env $APP_NAME | sed -n '/^VCAP_SERVICES:/,/^$/{//!p;}')"

# Rollbar
cf set-env $APP_NAME ROLLBAR_ACCESS_TOKEN $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-rollbar").credentials."access-token"')
cf set-env $APP_NAME ROLLBAR_ENV $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-rollbar").credentials.env')

# Logit.io
cf set-env $APP_NAME LOGIT_HOSTNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-logitio").credentials.host')
cf set-env $APP_NAME LOGIT_REMOTE_PORT $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-logitio").credentials.port')

# Papertrail
cf set-env $APP_NAME PAPERTRAIL_HOSTNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-papertrail").credentials.host')
cf set-env $APP_NAME PAPERTRAIL_REMOTE_PORT $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-papertrail").credentials.port')

# General BaT Client
cf set-env $APP_NAME BASICAUTH_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general-client").credentials."basicauth-username"')
cf set-env $APP_NAME BASICAUTH_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general-client").credentials."basicauth-password"')
cf set-env $APP_NAME SESSION_COOKIE_SECRET $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general-client").credentials."session-cookie-secret"')

# Static / miscellaneous
cf set-env $APP_NAME DOCUMENTS_TERMS_AND_CONDITIONS_URL "https://www.crowncommercial.gov.uk/agreements/RM6147"
# cf set-env $APP_NAME PORT 8080
cf set-env $APP_NAME BASICAUTH_ENABLED "true"

#######################
# Restage and start
#######################
cf restage $APP_NAME
