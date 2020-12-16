#!/bin/bash
#
# Applies (creates / updates) the CF infra
#

echo "ORG=${ORG}"
echo "ENV=${ENV}"
echo "ACTION=${ACTION}"
echo "SCOPE=${SCOPE}"

# Load global defaults and environment specific config
. ./config/global.properties
. ./config/$ENV.properties

cf target -o $ORG -s $SPACE

# Check AWS credentials set in environment for app deployment
if [[ ( $SCOPE =~ app|all ) && ( -z "${AWS_ECR_REPO_ACCESS_KEY_ID}" || -z "${AWS_ECR_REPO_SECRET_ACCESS_KEY}" ) ]]; then
  echo "Environment vars 'AWS_ECR_REPO_ACCESS_KEY_ID' and 'AWS_ECR_REPO_SECRET_ACCESS_KEY' required for app deployment"
  exit 1;
fi

# Create / update backing services
if [[ $SCOPE =~ svcs|all ]]; then
  . ./scripts/create-services.sh
fi

# Create / update applications
if [[ $SCOPE =~ app|all ]]; then
  . ./scripts/create-spree-apps.sh
  # . ./scripts/create-bat-client-app.sh
fi
