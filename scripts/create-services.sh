#!/bin/bash

##################
# Postgres Service
##################
cf create-service postgres $SERVICE_PLAN_PG $(expand_var ${SERVICE_NAME_PG})

#######################
# Elasticsearch Service
#######################
cf create-service elasticsearch $SERVICE_PLAN_ES $(expand_var ${SERVICE_NAME_ES})

###############
# Redis Services (frontend cache / sidekiq)
###############
cf create-service redis $SERVICE_PLAN_REDIS_CACHE $(expand_var ${SERVICE_NAME_REDIS_CACHE})
cf create-service redis $SERVICE_PLAN_REDIS_SIDEKIQ $(expand_var ${SERVICE_NAME_REDIS_SIDEKIQ})

###################
# Memcached Service
###################
# TBD -https://docs.cloud.service.gov.uk/deploying_services/user_provided_services/#user-provided-backing-services?

#############
# S3 Services
#############
cf create-service aws-s3-bucket default $(expand_var $SERVICE_NAME_S3_SPREE_IMAGES)
cf create-service aws-s3-bucket default $(expand_var $SERVICE_NAME_S3_SPREE_CNET)
cf create-service aws-s3-bucket default $(expand_var $SERVICE_NAME_S3_SPREE_PRODUCTS)

#############
# User-Provided Services
# Encapsulates external service details including credentials. Prompts for user input.
#############
create_update_ups () {
  UPS_NAME=$1
  UPS_LABEL=$2
  UPS_PROPS=$3

  # If the service already exists, update it otherwise create it
  if cf service $UPS_NAME &> /dev/null; then
    # TODO: Create github issue - input prompt does not work
    # https://github.com/cloudfoundry/cli/issues
    echo "Update $UPS_LABEL service details as prompted:"
    # cf uups $UPS_NAME -p "$UPS_PROPS"
  else
    echo "Enter $UPS_LABEL service details as prompted:"
    cf cups $UPS_NAME -p "$UPS_PROPS"
  fi
}

if [[ $PROVISION_UPS ]]; then
  NR_UPS_NAME=$(expand_var $UPS_NAME_NEWRELIC)
  NR_UPS_LABEL="New Relic"
  NR_PROPS="appname, license-key, enabled"
  create_update_ups "${NR_UPS_NAME}" "${NR_UPS_LABEL}" "${NR_PROPS}"

  RB_UPS_NAME=$(expand_var $UPS_NAME_ROLLBAR)
  RB_UPS_LABEL="Rollbar"
  RB_PROPS="access-token, env"
  create_update_ups "$RB_UPS_NAME" "$RB_UPS_LABEL" "$RB_PROPS"

  LGT_UPS_NAME=$(expand_var $UPS_NAME_LOGITIO)
  LGT_UPS_LABEL="Logit.io"
  LGT_PROPS="host, port"
  create_update_ups "$LGT_UPS_NAME" "$LGT_UPS_LABEL" "$LGT_PROPS"

  SGRD_UPS_NAME=$(expand_var $UPS_NAME_SENDGRID)
  SGRD_UPS_LABEL="Sendgrid"
  SGRD_PROPS="username, password"
  create_update_ups "$SGRD_UPS_NAME" "$SGRD_UPS_LABEL" "$SGRD_PROPS"

  GNRL_UPS_NAME=$(expand_var $UPS_NAME_GENERAL)
  GNRL_UPS_LABEL="generic Spree/Sidekiq"
  GNRL_PROPS="basicauth-username, basicauth-password, secret-key-base, sidekiq-username, sidekiq-password"
  create_update_ups "$GNRL_UPS_NAME" "$GNRL_UPS_LABEL" "$GNRL_PROPS"
fi
