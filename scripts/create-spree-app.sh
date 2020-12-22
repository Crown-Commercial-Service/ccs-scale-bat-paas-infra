#!/bin/bash

#######################
# Spree App
#######################
if [[ "$SIDEKIQ" = true ]]; then
  cf push -k $DISK_SPREE_SIDEKIQ -m $MEMORY_SPREE_SIDEKIQ -i $INSTANCES_SPREE_SIDEKIQ $APP_NAME \
    --docker-image $DOCKER_IMAGE_SPREE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID \
    -c "bundle exec sidekiq" --no-start --no-route -u process
else
  cf push -k $DISK_SPREE_UI -m $MEMORY_SPREE_UI -i $INSTANCES_SPREE_UI $APP_NAME \
    --docker-image $DOCKER_IMAGE_SPREE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID \
    -c "bundle exec rails server" --no-start

  # Map an internal route to Spree backend for client
  cf map-route $APP_NAME apps.internal --hostname $APP_NAME
fi

#######################
# Bind to Services
#######################
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_PG)
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_ES)
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_REDIS_CACHE)
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_REDIS_SIDEKIQ)
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_S3_SPREE_IMAGES)
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_S3_SPREE_CNET)
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_S3_SPREE_PRODUCTS)

# UPS
cf bind-service $APP_NAME $(expand_var $UPS_NAME_GENERAL)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_ROLLBAR)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_LOGITIO)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_SENDGRID)
cf bind-service $APP_NAME $(expand_var $UPS_NAME_NEWRELIC)

##################################
# Set Environment Variables in App
##################################

# TODO: Improve the sed command to remove need to prefix with additional '{' char
VCAP_SERVICES="{$(cf env $APP_NAME | sed -n '/^VCAP_SERVICES:/,/^$/{//!p;}')"

echo "${VCAP_SERVICES}"
echo "${ENV}"
echo "${APP_NAME}"

# S3 - Spree Images Bucket - TODO: SINF-224 Update to new env vars (commented lines)
cf set-env $APP_NAME S3_BUCKET_NAME $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.bucket_name')
# cf set-env $APP_NAME S3_BUCKET_NAME_IMAGES $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.bucket_name')
cf set-env $APP_NAME AWS_ACCESS_KEY_ID $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_access_key_id')
# cf set-env $APP_NAME S3_BUCKET_ACCESS_KEY_ID_IMAGES $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_access_key_id')
cf set-env $APP_NAME AWS_SECRET_ACCESS_KEY $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_secret_access_key')
# cf set-env $APP_NAME S3_BUCKET_SECRET_KEY_IMAGES $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_secret_access_key')

# S3 - Product imports bucket - TODO: SINF-224 Update to new env vars (commented lines)
cf set-env $APP_NAME PRODUCTS_IMPORT_BUCKET $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.bucket_name')
# cf set-env $APP_NAME S3_BUCKET_NAME_PRODUCTS_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.bucket_name')
# cf set-env $APP_NAME S3_BUCKET_ACCESS_KEY_ID_PRODUCTS_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.aws_access_key_id')
# cf set-env $APP_NAME S3_BUCKET_SECRET_KEY_PRODUCTS_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.aws_secret_access_key')

# S3 - CNET imports bucket - TODO: SINF-224 Update to new env vars (commented lines)
# cf set-env $APP_NAME S3_BUCKET_NAME_CNET_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-cnet-import").credentials.bucket_name')
# cf set-env $APP_NAME S3_BUCKET_ACCESS_KEY_ID_CNET_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-cnet-import").credentials.aws_access_key_id')
# cf set-env $APP_NAME S3_BUCKET_SECRET_KEY_CNET_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-cnet-import").credentials.aws_secret_access_key')

# Postgres, Redis, Elasticsearch etc
cf set-env $APP_NAME DB_HOST $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.host')
cf set-env $APP_NAME DB_NAME $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.name')
cf set-env $APP_NAME DB_USERNAME $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.username')
cf set-env $APP_NAME DB_PASSWORD $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.password')
cf set-env $APP_NAME ELASTICSEARCH_URL $(echo $VCAP_SERVICES | jq -r '."elasticsearch"[] | select(.name == env.ENV + "-es").credentials.uri')
cf set-env $APP_NAME REDIS_URL $(echo $VCAP_SERVICES | jq -r '."redis"[] | select(.name == env.ENV + "-redis-sidekiq").credentials.uri')

# Rollbar
cf set-env $APP_NAME ROLLBAR_ACCESS_TOKEN $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-rollbar").credentials."access-token"')
cf set-env $APP_NAME ROLLBAR_ENV $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-rollbar").credentials.env')

# New Relic
cf set-env $APP_NAME NEW_RELIC_LICENSE_KEY "$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-newrelic").credentials."license-key"')"
cf set-env $APP_NAME NEW_RELIC_APP_NAME "$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-newrelic").credentials.appname')"
cf set-env $APP_NAME NEW_RELIC_AGENT_ENABLED "$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-newrelic").credentials.enabled')"

# Logit.io
cf set-env $APP_NAME LOGIT_HOSTNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-logitio").credentials.host')
cf set-env $APP_NAME LOGIT_REMOTE_PORT $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-logitio").credentials.port')

# Sendgrid
cf set-env $APP_NAME SENDGRID_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-sendgrid").credentials.username')
cf set-env $APP_NAME SENDGRID_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-sendgrid").credentials.password')

# General Spree/Sidekiq
cf set-env $APP_NAME BASICAUTH_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."basicauth-username"')
cf set-env $APP_NAME BASICAUTH_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."basicauth-password"')
cf set-env $APP_NAME SECRET_KEY_BASE $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."secret-key-base"')
cf set-env $APP_NAME SIDEKIQ_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."sidekiq-username"')
cf set-env $APP_NAME SIDEKIQ_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."sidekiq-password"')

# Static / miscellaneous
cf set-env $APP_NAME APP_DOMAIN "$APP_NAME.london.cloudapps.digital"
cf set-env $APP_NAME AWS_REGION "$AWS_REGION"
cf set-env $APP_NAME S3_REGION "$AWS_REGION"
cf set-env $APP_NAME BASICAUTH_ENABLED "true"

#######################
# Restage and start
#######################
cf restage $APP_NAME
