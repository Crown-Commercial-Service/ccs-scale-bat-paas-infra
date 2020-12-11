#!/bin/bash
#
# Applies (creates / updates) the CF infra
#

echo "ORG=${ORG}"
echo "ENV=${ENV}"
echo "ACTION=${ACTION}"
echo "SCOPE=${SCOPE}"

cf target -o $ORG -s $(get_environment_property "SPACE")

# Create / update backing services
if [[ $SCOPE =~ svcs|all ]]; then
  . ./scripts/create-services.sh
fi

# Create / update applications
if [[ $SCOPE =~ app|all ]]; then
    . ./scripts/create-apps.sh
fi
