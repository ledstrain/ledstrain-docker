#!/usr/bin/env bash

#################
# This runs flarums scheduler at a regular interval. Some plugins may use this
# There is a healthcheck that is run if provided that uses the healthchecks.io
#  software.
################

# hc_schedule from healthcheck.io should be available in environment
healthcheck_address="$hc_schedule"

if [ -z ${healthcheck_address+x} ]; then
  (
    cd /app && php flarum schedule:run
  ) &> /dev/null
else
  (
    cd /app && php flarum schedule:run
  ) &> /dev/null && curl --silent --retry 3 -m 10 "$healthcheck_address" 1> /dev/null
fi
