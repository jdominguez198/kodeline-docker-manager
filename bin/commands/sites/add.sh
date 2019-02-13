#!/bin/bash

if [[ -z "$1" ]]; then
    echo "You must specify the site name"
    exit 1
fi

if [[ ! "$1" =~ [0-9a-z\_\-][^\.]+ ]]; then
    echo "The site name must match the pattern [0-9a-z\_\-][^\.]+"
    exit 1
fi

if [[ -z "$2" ]]; then
    SITE_FILES_DIR="/www/kodeline/$1"
else
    SITE_FILES_DIR=$2
fi

if [[ -z "$3" ]]; then
    SITE_FILES_SUBDIR=""
else
    SITE_FILES_SUBDIR="$3/"
fi

BIN_DIR="$( cd "$( dirname $(dirname $(dirname "${BASH_SOURCE[0]}" )))" >/dev/null && pwd )"/
BASE_DIR="$(dirname "${BIN_DIR}" )"/
CNF_DIR=${BIN_DIR}cnf/

source ${CNF_DIR}config.sh

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
git clone ${MONODOCKER_REPOSITORY} ./ > /dev/null 2>&1
rm -rf .git
bin/cli setup --site-name=\"${SITE_NAME}\" \
    --site-dir=\"${SITE_FILES_DIR}\" \
    --php-fpm=\"7.2\" \
    --gulp-dir=\"tools\" \
    --gulp-script=\"npm start\" \
    --httpd-port=\"${RANDOM_PORT}\" \
    --browsersync-port=\"$(($RANDOM_PORT+1))\" \
    --browsersync-admin-port=\"$(($RANDOM_PORT+2))\"
cat << EOF > ${SITE_CONF}
server {
    listen 80;
    server_name ${SITE_NAME}.${SITE_DOMAIN};

    location / {
      proxy_pass         ${INTERNAL_HOST}:${RANDOM_PORT}/${SITE_FILES_SUBDIR};
      proxy_redirect     off;
      proxy_set_header   Host $host;
      proxy_set_header   X-Real-IP $remote_addr;
      proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Host $server_name;
    }
}
EOF

echo "The site was created successfully!"
exit 0