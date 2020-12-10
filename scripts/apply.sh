#!/bin/bash
#
# Applies (creates / updates) the CF infra
#

echo "ORG=${ORG}"
echo "SPACE=${SPACE}"
echo "ACTION=${ACTION}"
echo "SCOPE=${SCOPE}"

cf target -o $ORG -s $SPACE

if [[ $SCOPE =~ svcs|all ]]; then
  echo "applying svcs.."
fi

if [[ $SCOPE =~ app|all ]]; then
  echo "applying apps.."
fi

echo $(get_environment_property "instance_count")
