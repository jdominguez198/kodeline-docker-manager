#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage:"
    echo "site_name [--site-dir=/absolute/path/to/site] [--site-subdir=subdir] [--assets-dir=relative/path/to/assets/]"
    exit 1
fi

if [[ ! "$1" =~ [0-9a-z\_\-][^\.]+ ]]; then
    echo "The site name must match the pattern [0-9a-z\_\-][^\.]+"
    exit 1
fi

SITE_FILES_DIR="/www/kodeline/$1"
SITE_FILES_SUBDIR=""
SITE_ASSETS_DIR="./"

for i in "$@" ; do
    if [[ "$i" =~ "--site-dir" ]]; then
        SITE_FILES_DIR=$(echo $i | awk -F '--site-dir=' '{print $2}')
    fi
    if [[ "$i" =~ "--site-subdir" ]]; then
        SITE_FILES_SUBDIR=$(echo $i | awk -F '--site-subdir=' '{print $2}')
    fi
    if [[ "$i" =~ "--assets-dir" ]]; then
        SITE_ASSETS_DIR=$(echo $i | awk -F '--assets-dir=' '{print $2}')
    fi
done

BIN_DIR="$( cd "$( dirname $(dirname $(dirname "${BASH_SOURCE[0]}" )))" >/dev/null && pwd )"/
BASE_DIR="$(dirname "${BIN_DIR}" )"/
CNF_DIR=${BIN_DIR}cnf/

source ${CNF_DIR}config.sh
CONTAINERS_PATH=${BASE_DIR}${CONTAINERS_DIR}/

SITE_NAME=$1
RANDOM_PORT=$(awk 'BEGIN{srand();print int(rand()*(9990-9000))+9000 }')
while [[ $(lsof -Pi :${RANDOM_PORT} -sTCP:LISTEN -t >/dev/null) ]]; do
    RANDOM_PORT=$(awk 'BEGIN{srand();print int(rand()*(9990-9000))+9000 }')
done

SITE_CONF=${BASE_DIR}${SITES_DIR}/${SITE_NAME}.conf
SITE_DIR=${BASE_DIR}${WEBS_DIR}/${SITE_NAME}

if [[ -d "$SITE_DIR" ]]; then
    echo "The site already exists"
    exit 1
fi

echo "Creating site files for \"${SITE_NAME}\"..."

mkdir -p ${SITE_DIR}
cd ${SITE_DIR}
wget -qO- ${DOCKER_CMS_REPOSITORY} | tar -xzvf - -C ./ --strip-components 1
bin/cli setup \
    --php-fpm=7.1 \
    --apache=2.4.38 \
    --site-name=${SITE_NAME} \
    --site-dir=${SITE_FILES_DIR} \
    --site-assets-dir=${SITE_ASSETS_DIR} \
    --httpd-port=${RANDOM_PORT} \
    --browsersync-port=$(($RANDOM_PORT+1)) \
    --browsersync-admin-port=$(($RANDOM_PORT+2))
cat << EOF > ${SITE_CONF}
server {
    listen 80;
    server_name ${SITE_NAME}.${SITE_DOMAIN};

    location / {
      proxy_pass         ${INTERNAL_HOST}:${RANDOM_PORT}/${SITE_FILES_SUBDIR};
      proxy_redirect     off;
      proxy_set_header   Host \$host;
      proxy_set_header   X-Real-IP \$remote_addr;
      proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Host \$server_name;
    }
}
EOF

cd ${BASE_DIR}
sed 's/\(=[[:blank:]]*\)\(.*\)/\1"\2"/' ${CONTAINERS_PATH}.env > ${CONTAINERS_PATH}.env.vars
source ${CONTAINERS_PATH}.env.vars
rm -f ${CONTAINERS_PATH}.env.vars

if [[ "$(docker ps -q -f name=${PROXY_CONTAINER_PREFIX})" ]]; then
    echo "Reloading proxy..."
    bin/cli proxy:reload > /dev/null 2>&1
fi

echo "The site was created and added to the proxy successfully!"
exit 0