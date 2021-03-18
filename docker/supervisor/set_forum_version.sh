#!/usr/bin/env bash
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
