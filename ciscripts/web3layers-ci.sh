#!/bin/bash
#
#
set -e
set -o pipefail
set -u
set -x

# required shell params

: "${YUM_HOST:?"should not be empty"}"

# run instances

## db

eval "$(${BASH_SOURCE[0]%/*}/runner-db.sh)"
db_id="${instance_id}"
DB_HOST="${ipaddr}"

## app

eval "$(
 YUM_HOST="${YUM_HOST}" \
  DB_HOST="${DB_HOST}"  \
  ${BASH_SOURCE[0]%/*}/runner-app.sh
 )"
app_id="${instance_id}"
APP_HOST="${ipaddr}"

## trap

trap "
 mussel instance destroy \"${db_id}\"
 mussel instance destroy \"${app_id}\"
" ERR

# smoketest

## app

## need to wait for api to be running
## need to wait for web to be running

APP_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-app.sh

# cleanup instances

${BASH_SOURCE[0]%/*}/instance-kill.sh "${db_id}"
${BASH_SOURCE[0]%/*}/instance-kill.sh "${app_id}"
