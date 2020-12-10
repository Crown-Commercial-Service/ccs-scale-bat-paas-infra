#!/bin/bash
#
# CCS Scale BaT - GPaaS Cloud Foundry provisioning control script
# Usage:
# cf-bat apply|destroy [-o ] --space sandbox|development --scope bs|app|all
#

set -meo pipefail

usage() { echo "Usage: $0 [-o <ccs-scale-bat>] [-s <sandbox|development|INT>] <apply|destroy> <svcs|apps|all>" 1>&2; exit 1; }

get_environment_property () {
  cat ${PROPERTY_FILE} | grep -w "$1" | cut -d'=' -f2
}

while getopts ":o:s:" o; do
    case "${o}" in
        o)
            ORG=${OPTARG:='ccs-scale-bat'}
            ;;
        s)
            SPACE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Check null/empty options and args
if [ -z "${ORG}" ] || [ -z "${SPACE}" ] || [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

ACTION=$1
SCOPE=$2
PROPERTY_FILE="./space/${SPACE}.properties"

if [[ ! -f $PROPERTY_FILE ]]; then
  echo "Space (env) config file [$PROPERTY_FILE] not found"
  exit 1;
fi

if [[ $ACTION = "apply" ]]; then
  . ./scripts/apply.sh
elif [[ $ACTION = "destroy" ]]; then
  . ./scripts/destroy.sh
else
  echo "Unrecognised action [$ACTION]. Only 'apply or 'destroy' are valid."
  usage
fi
