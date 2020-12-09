#!/bin/bash
#
# CCS Scale BaT - GPaaS Cloud Foundry provisioning control script
# Usage:
# cf-bat apply|destroy [-o ] --space sandbox|development --scope bs|app|all
#

set -meo pipefail

usage() { echo "Usage: $0 [-o <ccs-scale-bat>] [-s <sandbox|development|INT>] <apply|destroy> <svcs|apps|all>" 1>&2; exit 1; }

while getopts ":o:s:" o; do
    case "${o}" in
        o)
            ORG=${OPTARG}
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
if [ -z "${ORG}" ] || [ -z "${SPACE}" || [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

# Validate args
# TODO: Org = ccs-scale-bat, space = sandbox etc, action=<apply|destroy> scope=<svcs|apps|all>

echo "ORG=${ORG}"
echo "SPACE=${SPACE}"
echo "ACTION=${1}"
echo "SCOPE=${2}"

export PROPERTY_FILE="./space/${SPACE}.properties"

get_environment_property () {
  cat ${PROPERTY_FILE} | grep -w "$1" | cut -d'=' -f2
}

echo $(get_environment_property "instance_count")
