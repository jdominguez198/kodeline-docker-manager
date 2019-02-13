#!/bin/bash

if [[ -z "$1" ]]; then
    echo "You must specify the site name"
    exit 1
fi

BIN_DIR="$( cd "$( dirname $(dirname $(dirname "${BASH_SOURCE[0]}" )))" >/dev/null && pwd )"/
BASE_DIR="$(dirname "${BIN_DIR}" )"/
CNF_DIR=${BIN_DIR}cnf/

source ${CNF_DIR}config.sh

SITE_NAME=$1
SITE_CONF=${BASE_DIR}${SITES_DIR}/${SITE_NAME}.conf
SITE_DIR=${BASE_DIR}${WEBS_DIR}/${SITE_NAME}

if [[ ! -d "$SITE_DIR" ]]; then
    echo "The site does not exists"
    exit 1
fi

rm -rf ${SITE_DIR}
rm -rf ${SITE_CONF}

echo "The site was removed successfully!"
exit 0