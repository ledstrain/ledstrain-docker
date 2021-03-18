#!/usr/bin/env bash
response="-1"
data="{"custom_footer":"<div id=img_version>$IMAGE_VERSION</div>"}"

while [ "$response" -ne "204" ]; do
  response=$(curl                                            \
    --silent                                                 \
    --insecure                                               \
    --write-out '%{response_code}'                           \
    --retry 6 --fail  --retry-connrefused --retry-delay 10   \
    --request POST --url https://$HOSTNAME/api/settings      \
    --header "Authorization: Token $MASTER_TOKEN;userId=1"   \
    --header 'Content-Type: application/json; charset=utf-8' \
    --header "Origin: https://$HOSTNAME"                     \
    --data "$data")
  echo "Footer Version Update: $IMAGE_VERSION" 1> /proc/1/fd/1 2> /proc/1/fd/2
  if [ "$response" -eq "204" ]; then continue; fi
  sleep 5
done
