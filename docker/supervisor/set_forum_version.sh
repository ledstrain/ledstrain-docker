#!/usr/bin/env bash

#################
# This code runs a simple query to /api/settings to change the custom footer
# It requires a api_key (or master token) which is represented by MASTER_TOKEN
# By doing this on load up, it should always get the right image version
#  which is represented by IMAGE_VERSION
# We run this with supervisor instead of cron because cron does not provide
#  environment variables, which we need to do our query
#################

response="-1"
data='{"custom_footer":"<div id=img_version>'$IMAGE_VERSION'</div>"}'

sleep 10
response=$(curl                                            \
  --silent                                                 \
  --insecure                                               \
  --write-out '%{response_code}'                           \
  --request POST --url "https://$HOSTNAME/api/settings"    \
  --header "Authorization: Token $MASTER_TOKEN;userId=1"   \
  --header 'Content-Type: application/json; charset=utf-8' \
  --header "Origin: https://$HOSTNAME"                     \
  --data "$data")
if [ "$response" -eq "204" ]; then
  echo "Image Version (footer): $IMAGE_VERSION" 1> /proc/1/fd/1 2> /proc/1/fd/2
else
  exit 1
fi
