#!/bin/bash

BIN_DIR="$( cd "$( dirname $(dirname $(dirname "${BASH_SOURCE[0]}" )))" >/dev/null && pwd )"/
BASE_DIR="$(dirname "${BIN_DIR}" )"/
CNF_DIR=${BIN_DIR}cnf/

source ${CNF_DIR}config.sh

CONTAINERS_PATH=${BASE_DIR}${CONTAINERS_DIR}/

if [[ ! -f ${CONTAINERS_PATH}.env ]]; then
    echo "You must create and setup the file \"${CONTAINERS_PATH}\""
    exit 1
else
    sed 's/\(=[[:blank:]]*\)\(.*\)/\1"\2"/' ${CONTAINERS_PATH}.env > ${CONTAINERS_PATH}.env.vars
    source ${CONTAINERS_PATH}.env.vars
    rm -f ${CONTAINERS_PATH}.env.vars
fi

cd ${CONTAINERS_PATH}

if [[ "$(docker ps -q -f name=${PROXY_CONTAINER_PREFIX})" ]]; then
    echo "The proxy is already running"
    exit 1
fi

echo "Starting proxy..."
docker-compose -p ${PROXY_CONTAINER_PREFIX} up -d