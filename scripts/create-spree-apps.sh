#!/bin/bash

export CF_DOCKER_PASSWORD=$AWS_ECR_REPO_SECRET_ACCESS_KEY
APP_SPREE_UI=$(expand_var $APP_NAME_SPREE_UI)

#######################
# Spree App
#######################
cf push -k $DISK_SPREE_UI -m $MEMORY_SPREE_UI -i $INSTANCES_SPREE_UI $APP_SPREE_UI \
  --docker-image $DOCKER_IMAGE_SPREE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID --no-start

#######################
# Bind to Services
#######################
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_PG)
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_ES)
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_REDIS_CACHE)
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_REDIS_SIDEKIQ)
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_S3_SPREE_IMAGES)
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_S3_SPREE_CNET)
cf bind-service $APP_SPREE_UI $(expand_var $SERVICE_NAME_S3_SPREE_PRODUCTS)

# UPS
cf bind-service $APP_SPREE_UI $(expand_var $UPS_NAME_GENERAL)
cf bind-service $APP_SPREE_UI $(expand_var $UPS_NAME_ROLLBAR)
cf bind-service $APP_SPREE_UI $(expand_var $UPS_NAME_LOGITIO)
cf bind-service $APP_SPREE_UI $(expand_var $UPS_NAME_SENDGRID)
cf bind-service $APP_SPREE_UI $(expand_var $UPS_NAME_NEWRELIC)

##################################
# Set Environment Variables in App
##################################

VCAP_SERVICES="{$(cf env $APP_SPREE_UI | sed -n '/^VCAP_SERVICES:/,/^$/{//!p;}')"

# S3 - Spree Images Bucket - TODO: SINF-224 Update to new env vars (commented lines)
cf set-env $APP_SPREE_UI S3_BUCKET_NAME $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.bucket_name')
# cf set-env $APP_SPREE_UI S3_BUCKET_NAME_IMAGES $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.bucket_name')
cf set-env $APP_SPREE_UI AWS_ACCESS_KEY_ID $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_access_key_id')
# cf set-env $APP_SPREE_UI S3_BUCKET_ACCESS_KEY_ID_IMAGES $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_access_key_id')
cf set-env $APP_SPREE_UI AWS_SECRET_ACCESS_KEY $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_secret_access_key')
# cf set-env $APP_SPREE_UI S3_BUCKET_SECRET_KEY_IMAGES $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-images").credentials.aws_secret_access_key')

# S3 - Product imports bucket - TODO: SINF-224 Update to new env vars (commented lines)
cf set-env $APP_SPREE_UI PRODUCTS_IMPORT_BUCKET $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.bucket_name')
# cf set-env $APP_SPREE_UI S3_BUCKET_NAME_PRODUCTS_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.bucket_name')
# cf set-env $APP_SPREE_UI S3_BUCKET_ACCESS_KEY_ID_PRODUCTS_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.aws_access_key_id')
# cf set-env $APP_SPREE_UI S3_BUCKET_SECRET_KEY_PRODUCTS_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-products-import").credentials.aws_secret_access_key')

# S3 - CNET imports bucket - TODO: SINF-224 Update to new env vars (commented lines)
# cf set-env $APP_SPREE_UI S3_BUCKET_NAME_CNET_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-cnet-import").credentials.bucket_name')
# cf set-env $APP_SPREE_UI S3_BUCKET_ACCESS_KEY_ID_CNET_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-cnet-import").credentials.aws_access_key_id')
# cf set-env $APP_SPREE_UI S3_BUCKET_SECRET_KEY_CNET_IMPORT $(echo $VCAP_SERVICES | jq -r '."aws-s3-bucket"[] | select(.name == env.ENV + "-spree-cnet-import").credentials.aws_secret_access_key')

# Postgres, Redis, Elasticsearch etc
cf set-env $APP_SPREE_UI DB_HOST $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.host')
cf set-env $APP_SPREE_UI DB_NAME $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.name')
cf set-env $APP_SPREE_UI DB_USERNAME $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.username')
cf set-env $APP_SPREE_UI DB_PASSWORD $(echo $VCAP_SERVICES | jq -r '."postgres"[] | select(.name == env.ENV + "-pg").credentials.password')
cf set-env $APP_SPREE_UI ELASTICSEARCH_URL $(echo $VCAP_SERVICES | jq -r '."elasticsearch"[] | select(.name == env.ENV + "-es").credentials.uri')
cf set-env $APP_SPREE_UI REDIS_URL $(echo $VCAP_SERVICES | jq -r '."redis"[] | select(.name == env.ENV + "-redis-sidekiq").credentials.uri')

# Rollbar
cf set-env $APP_SPREE_UI ROLLBAR_ACCESS_TOKEN $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-rollbar").credentials."access-token"')
cf set-env $APP_SPREE_UI ROLLBAR_ENV $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-rollbar").credentials.env')

# New Relic
cf set-env $APP_SPREE_UI NEW_RELIC_LICENSE_KEY "$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-newrelic").credentials."license-key"')"
cf set-env $APP_SPREE_UI NEW_RELIC_APP_NAME "$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-newrelic").credentials.appname')"
cf set-env $APP_SPREE_UI NEW_RELIC_AGENT_ENABLED "$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-newrelic").credentials.enabled')"

# Logit.io
cf set-env $APP_SPREE_UI LOGIT_HOSTNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-logitio").credentials.host')
cf set-env $APP_SPREE_UI LOGIT_REMOTE_PORT $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-logitio").credentials.port')

# Sendgrid
cf set-env $APP_SPREE_UI SENDGRID_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-sendgrid").credentials.username')
cf set-env $APP_SPREE_UI SENDGRID_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-sendgrid").credentials.password')

# General Spree/Sidekiq
cf set-env $APP_SPREE_UI BASICAUTH_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."basicauth-username"')
cf set-env $APP_SPREE_UI BASICAUTH_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."basicauth-password"')
cf set-env $APP_SPREE_UI SECRET_KEY_BASE $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."secret-key-base"')
cf set-env $APP_SPREE_UI SIDEKIQ_USERNAME $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."sidekiq-username"')
cf set-env $APP_SPREE_UI SIDEKIQ_PASSWORD $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV + "-ups-general").credentials."sidekiq-password"')

# Static / miscellaneous
cf set-env $APP_SPREE_UI APP_DOMAIN "$APP_SPREE_UI.london.cloudapps.digital"
cf set-env $APP_SPREE_UI AWS_REGION "$AWS_REGION"
cf set-env $APP_SPREE_UI S3_REGION "$AWS_REGION"
cf set-env $APP_SPREE_UI BASICAUTH_ENABLED "true"

#######################
# Restage and start
#######################
cf restage $APP_SPREE_UI

#######################
# Buyer UI App
#######################
# cf push -k $SPREE_APP_DISK -m $SPREE_APP_MEMORY -i $SPREE_APP_INSTANCES $APP_SPREE_UI --docker-image $SPREE_APP_IMAGE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID
