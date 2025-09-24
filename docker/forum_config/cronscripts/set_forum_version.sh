#!/usr/bin/env bash

#################
# This code runs a simple query to /api/settings to change the custom footer
# It requires a api_key (or master token) which is represented by MASTER_TOKEN
# By doing this on load up, it should always get the right image version
#  which is represented by IMAGE_VERSION
# We run this with supervisor instead of cron because cron does not provide
#  environment variables, which we need to do our query
#################
GREEN='\033[1;32m'
NC='\033[0m' # No Color
sleep 5

response="-1"
IMAGE_VERSION="$(echo "${BUILD_COMMIT:-dev}" | cut -b1-7)"
data='{"custom_footer":"<div id=img_version>'$IMAGE_VERSION'</div>"}'

while [ "$response" -ne "204" ]; do
  response=$(curl                                            \
    --silent                                                 \
    --insecure                                               \
    --write-out '%{response_code}'                           \
    --request POST --url "http://localhost/api/settings"    \
    --header "Authorization: Token $MASTER_TOKEN;userId=1"   \
    --header 'Content-Type: application/json; charset=utf-8' \
    --header "Origin: https://$HOSTNAME"                     \
    --data "$data")
  if [ "$response" -eq "204" ]; then
    echo -e "Image Version (footer): ${GREEN}$IMAGE_VERSION${NC}" 2>&1 | logger -t set-forum-version
    unset MASTER_TOKEN
    (
      cd /app || exit
      php flarum cache:clear
      php flarum cache:assets --js --css --locales || true
    )
    break
  else
    sleep 10
  fi
done
