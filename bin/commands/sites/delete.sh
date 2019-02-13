#!/bin/bash

if [[ -z "$1" ]]; then
    echo "You must specify the site name"
    exit 1
fi

BIN_DIR="$( cd "$( dirname $(dirname $(dirname "${BASH_SOURCE[0]}" )))" >/dev/null && pwd )"/
BASE_DIR="$(dirname "${BIN_DIR}" )"/
CNF_DIR=${BIN_DIR}cnf/

source ${CNF_DIR}config.sh

CONTAINERS_PATH=${BASE_DIR}${CONTAINERS_DIR}/

SITE_NAME=$1
SITE_CONF=${BASE_DIR}${SITES_DIR}/${SITE_NAME}.conf
SITE_DIR=${BASE_DIR}${WEBS_DIR}/${SITE_NAME}

if [[ ! -d "$SITE_DIR" ]]; then
    echo "The site does not exists"
    exit 1
fi

rm -rf ${SITE_DIR}
rm -rf ${SITE_CONF}

cd ${BASE_DIR}
sed 's/\(=[[:blank:]]*\)\(.*\)/\1"\2"/' ${CONTAINERS_PATH}.env > ${CONTAINERS_PATH}.env.vars
source ${CONTAINERS_PATH}.env.vars
rm -f ${CONTAINERS_PATH}.env.vars

if [[ "$(docker ps -q -f name=${PROXY_CONTAINER_PREFIX})" ]]; then
    echo "Reloading proxy..."
    bin/cli proxy:reload > /dev/null 2>&1
fi

echo "The site was deleted and removed from the proxy successfully!"
exit 0