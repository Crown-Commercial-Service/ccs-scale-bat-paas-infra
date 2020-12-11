#!/bin/bash
#
# CCS Scale BaT - GPaaS Cloud Foundry provisioning control script
# Usage:
# cf-bat apply|destroy [-o ] --space sandbox|development --scope bs|app|all
#

set -meo pipefail

usage() { echo "Usage: $0 [-o <ccs-scale-bat>] [-e <sandbox|development|int>] <apply|destroy> <svcs|apps|all>" 1>&2; exit 1; }

get_environment_property () {
  cat ${ENV_PROPS} | grep -w "$1" | cut -d'=' -f2
}

resolve_env_property () {
  echo $(eval echo "$1")
}

while getopts ":o:e:" o; do
    case "${o}" in
        o)
            ORG=${OPTARG:='ccs-scale-bat'}
            ;;
        e)
            ENV=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Check null/empty options and args
if [ -z "${ORG}" ] || [ -z "${ENV}" ] || [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

ACTION=$1
SCOPE=$2
ENV_PROPS="./config/${ENV}.properties"

if [[ ! -f $ENV_PROPS ]]; then
  echo "Environment (space) config file [$ENV_PROPS] not found"
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
