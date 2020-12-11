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

# Create / update backing services
if [[ $SCOPE =~ svcs|all ]]; then
  . ./scripts/create-services.sh
fi

# Create / update applications
if [[ $SCOPE =~ app|all ]]; then
  . ./scripts/create-spree-apps.sh
  . ./scripts/create-bat-client-app.sh
fi
